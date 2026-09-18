import Foundation


// Шаг 1: Личная информация

let firstName: String = "Mukhamedali"
let lastName: String = "Kazykhan"
let birthYear: Int = 2006
let currentYear: Int = 2026
let age: Int = currentYear - birthYear
let isStudent: Bool = true
let height: Double = 1.75

let city: String = "Алматы"
let favoriteColor: String = "синий"


// Шаг 2: Хобби

let hobby: String = "программирование"
let numberOfHobbies: Int = 3
let favoriteNumber: Int = 7
let isHobbyCreative: Bool = true

// Бонус: emoji
let 😀mood: String = "счастливый"
let 🎯futureGoals: String = "стать профессиональным iOS-разработчиком"


// Шаг 3: Рассказ

let lifeStory: String = """
Меня зовут \(firstName) \(lastName).
Мне \(age) лет, я родился в \(birthYear) году.
Сейчас я \(isStudent ? "студент" : "не студент").
Мой рост — \(height) м.
Я живу в \(city), мой любимый цвет — \(favoriteColor).
Я увлекаюсь \(hobby), и это \(isHobbyCreative ? "творческое" : "не творческое") хобби.
Всего у меня \(numberOfHobbies) хобби, и моё любимое число — \(favoriteNumber).
Сейчас я \(😀mood).
В будущем я хочу \(🎯futureGoals).
"""

// 4: Печатаем


print(lifeStory)
