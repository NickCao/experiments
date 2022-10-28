import matplotlib.pyplot as plt
import csv

sizes = []
labels = []
with open('result', newline='') as csvfile:
     reader = csv.reader(csvfile, delimiter=' ')
     for row in reader:
         sizes.append(int(row[-2]))
         labels.append(row[-1])
fig1, ax1 = plt.subplots()
ax1.pie(sizes, labels=labels, autopct='%1.1f%%', startangle=90)
ax1.axis('equal')
plt.show()
