package main

import (
	"context"
	"fmt"
	"github.com/chromedp/chromedp"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/stripe/stripe-go/v72"
	"github.com/stripe/stripe-go/v72/checkout/session"
	"net/http"
	"os"
	"strconv"
	"time"
)

const exp = `
var script = document.createElement('script')
script.type = 'text/javascript'
script.src = 'https://js.stripe.com/v3'
script.onload = function () {
    var stripe = Stripe('<stripe pubkey>')
    stripe.redirectToCheckout({ sessionId: '%s' })
};
document.head.appendChild(script)
`

func init() {
	stripe.Key = os.Getenv("STRIPE_API_KEY")
}

func main() {
	e := echo.New()
	e.Use(middleware.Logger())
	e.Use(middleware.CORS())

	e.GET("/", func(ctx echo.Context) error {
		amount, err := strconv.ParseInt(ctx.QueryParam("amount"), 10, 64)
		if err != nil {
			return ctx.String(http.StatusBadRequest, "required query param: amount (int)")
		}

		checkout, err := session.New(&stripe.CheckoutSessionParams{
			PaymentMethodTypes: stripe.StringSlice([]string{"alipay", "card"}),
			LineItems: []*stripe.CheckoutSessionLineItemParams{{
				Price:    stripe.String("<price object for 1 CNY>"),
				Quantity: stripe.Int64(amount),
			}},
			Mode:          stripe.String("payment"),
			SuccessURL:    stripe.String("<success url>"),
			CancelURL:     stripe.String("<cancel url>"),
			SubmitType:    stripe.String("donate"),
			CustomerEmail: stripe.String("<some stub email address>"),
		})
		if err != nil {
			e.Logger.Error(err)
			return ctx.String(http.StatusInternalServerError, "failed to create checkout session")
		}

		dp, cancel0 := chromedp.NewContext(context.Background())
		defer cancel0()
		c, cancel1 := context.WithTimeout(dp, time.Second*25)
		defer cancel1()
		var url string
		var res []byte
		err = chromedp.Run(c,
			chromedp.Navigate("<any url with https>"),
			chromedp.Evaluate(fmt.Sprintf(exp, checkout.ID), &res),
			chromedp.WaitVisible("#root > div > div > div.App-Payment"),
			chromedp.Location(&url))
		if err != nil {
			e.Logger.Error(err)
			return ctx.String(http.StatusInternalServerError, "failed to get checkout url")
		}
		return ctx.Redirect(http.StatusFound, url)
	})

	e.Logger.Fatal(http.ListenAndServe(":8080", e))
}
