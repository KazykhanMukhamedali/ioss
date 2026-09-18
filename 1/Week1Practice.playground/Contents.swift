let name = "Aisha"
var score = 0
score = 10

let count = 42
let price = 9.99
let title: String = "ios"
let ratio: Double = 5

let a = 5
let b = 2.0
let c = Double(a) + b

let n = 5
n.isMultiple(of: 2)
n.description

let first = "Arman"
var score2 = 10
let line = "Hello, \(first). You have \(score2) points."

var x = "hello"
var y = x
y.append(" world")
print(x)
print(y)

var numbers = [1, 2, 3]
var copy = numbers
copy.append(4)
print(numbers)
print(copy)

var ages = ["Ann": 30, "Bolat": 25]
ages["Chen"] = 41
print(ages["Ann"])

let score3 = 3
switch score3 {
case 0: print("none")
case 1..<5: print("low")
case 5...: print("high")
default: print("negative")
}

func greet(name: String) -> String {
    return "Hello, \(name)"
}
greet(name: "Aisha")

func move(from a: Int, to b: Int) { }
move(from: 0, to: 5)

func double(_ v: Int) -> Int { v * 2 }
double(5)

let point = (x: 3, y: 7)
print(point.x)


// Вопрос: почему в Swift массивы копируются при присваивании, а в Java — нет?
