import Cocoa


// EASY

let fruits = ["apple", "banana", "cherry", "date", "elderberry"]
print(fruits[2])

var favoriteNumbers: Set<Int> = [1, 2, 3, 7, 9]
favoriteNumbers.insert(42)
print(favoriteNumbers)

let languages = ["Swift": 2014, "Java": 1995, "Python": 1991]
print(languages["Swift"]!)

var colors = ["red", "green", "blue", "yellow"]
colors[1] = "purple"
print(colors)

// MEDIUM

let setA: Set<Int> = [1, 2, 3, 4]
let setB: Set<Int> = [3, 4, 5, 6]
print(setA.intersection(setB))

var scores = ["Ali": 85, "Aisha": 90, "Bolat": 78]
scores["Ali"] = 95
print(scores)

let array1 = ["apple", "banana"]
let array2 = ["cherry", "date"]
print(array1 + array2)

// HARD

var countries = ["Kazakhstan": 19_000_000, "Russia": 144_000_000, "China": 1_400_000_000]
countries["USA"] = 331_000_000
print(countries)

let setC: Set<String> = ["cat", "dog"]
let setD: Set<String> = ["dog", "mouse"]
let unionSet = setC.union(setD)
let finalSet = unionSet.subtracting(setD)
print(finalSet)

let studentGrades: [String: [Int]] = [
    "Ali": [90, 85, 88],
    "Aisha": [95, 92, 98],
    "Bolat": [70, 75, 80]
]
print(studentGrades["Ali"]![1])
