// =============================================================
//  Station ALMA-7
// =============================================================


// MARK: - =================== STARTER CODE ===================
// это трогать нельзя

typealias Reading = (sensor: String, value: Int)

func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int
    var module: Module?
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// =============================================================
//  МОЁ РЕШЕНИЕ
// =============================================================


// MARK: Level 1 - телеметрия

// 1.1 парсим одну строку с датчика
func parseReading(_ raw: String) -> Reading? {
    guard
        let parts = splitOnce(raw, by: ":"),
        !parts.0.isEmpty,
        let value = Int(parts.1),
        value >= 0 || parts.0 == "TEMP"
    else {
        return nil
    }
    return (sensor: parts.0, value: value)
}

print(parseReading("O2:87")    ?? "nil")
print(parseReading("TEMP:-12") ?? "nil")
print(parseReading("RAD:-1")   ?? "nil")
print(parseReading(":55")      ?? "nil")
print(parseReading("O2:9x")    ?? "nil")

// 1.2 прогоняю весь лог
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalid = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalid += 1
        }
    }
    return (valid: valid, invalidCount: invalid)
}

let log = parseLog(rawLog)
print("valid: \(log.valid.count), invalid: \(log.invalidCount)")

// фрагмент A
let A = log.invalidCount
print("A = \(A)")


// MARK: Level 2 - анализ

// 2.1 свой filter
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

let allReadings = log.valid
let o2Readings  = select(allReadings) { $0.sensor == "O2" }
print("O2 readings: \(o2Readings)")
print("O2 values:   \(values(of: o2Readings))")

// 2.2 min max average
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var minVal = first
    var maxVal = first
    var sum    = 0
    for v in values {
        if v < minVal { minVal = v }
        if v > maxVal { maxVal = v }
        sum += v
    }
    let avg = Double(sum) / Double(values.count)
    return (min: minVal, max: maxVal, average: avg)
}

// variadic версия просто вызывает первую
func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print(stats(of: [3, 8, 1]) ?? "nil")
print(stats(of: [10, 20])  ?? "nil")
print(stats(3, 8, 1)       ?? "nil")
print(stats(7, 7, 7, 7)    ?? "nil")
print(stats(of: [])        ?? "nil")
print(stats()              ?? "nil")

// фрагмент B
let o2Stats = stats(of: values(of: o2Readings))
var B = 0
if let s = o2Stats {
    B = Int(s.average)
}
print("B = \(B)")

// 2.3 пять сортировок по убыванию value

// 1 полный синтаксис
let sort1 = allReadings.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})

// 2 типы выведены
let sort2 = allReadings.sorted(by: { a, b in
    return a.value > b.value
})

// 3 implicit return
let sort3 = allReadings.sorted(by: { a, b in
    a.value > b.value
})

// 4 shorthand $0 $1
let sort4 = allReadings.sorted(by: { $0.value > $1.value })

// 5 trailing closure
let sort5 = allReadings.sorted { $0.value > $1.value }

// проверяю в коде что все пять одинаковые
func sameReadings(_ a: [Reading], _ b: [Reading]) -> Bool {
    guard a.count == b.count else { return false }
    for i in 0..<a.count {
        if a[i].sensor != b[i].sensor || a[i].value != b[i].value {
            return false
        }
    }
    return true
}

let ladderOK =
    sameReadings(sort1, sort2) &&
    sameReadings(sort2, sort3) &&
    sameReadings(sort3, sort4) &&
    sameReadings(sort4, sort5)

print("Closure Ladder all equal: \(ladderOK)")
print("Descending values: \(values(of: sort5))")


// MARK: Level 3 - температура

// 3.1 три функции одного типа
func heatUp(_ t: Int) -> Int   { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int     { t }

// возвращает функцию не вызывает
func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 { return heatUp }
    if temp > 24 { return coolDown }
    return hold
}

print("chooseProtocol(10)(10) = \(chooseProtocol(for: 10)(10))")
print("chooseProtocol(30)(30) = \(chooseProtocol(for: 30)(30))")
print("chooseProtocol(20)(20) = \(chooseProtocol(for: 20)(20))")

// 3.2 гоняем температуру пока не стабилизируется
func runUntilStable(from start: Int, maxSteps: Int = 10)
    -> (finalTemp: Int, steps: Int, isStable: Bool) {

    var temp  = start
    var steps = 0

    while (temp < 18 || temp > 24) && steps < maxSteps {
        let proto = chooseProtocol(for: temp)
        temp  = proto(temp)
        steps += 1
    }

    let stable = temp >= 18 && temp <= 24
    return (finalTemp: temp, steps: steps, isStable: stable)
}

print(runUntilStable(from: 31))
print(runUntilStable(from: -100, maxSteps: 5))

// фрагмент C - самая низкая TEMP из лога
let tempReadings = select(allReadings) { $0.sensor == "TEMP" }
let tempValues   = values(of: tempReadings)
print("TEMP values: \(tempValues)")

let tempStats = stats(of: tempValues)
var lowestTemp = 0
if let s = tempStats {
    lowestTemp = s.min
}
print("lowest TEMP = \(lowestTemp)")

let C = runUntilStable(from: lowestTemp).steps
print("C = \(C)")


// MARK: Level 4 - экипаж

// 4.1 одна строка через optional chaining
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

print("Timur:   \(oxygenLevel(of: crew[0]) ?? -1)")
print("Dana:    \(oxygenLevel(of: crew[1]) ?? -1)")
print("Aigerim: \(oxygenLevel(of: crew[2]) ?? -1)")
print("Nurlan:  \(oxygenLevel(of: crew[3]) ?? -1)")

// 4.2 статус
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let place = member.module?.name ?? "open space"
        return "\(member.name): no data (\(place))"
    }
    if level < 20 {
        return "\(member.name): \(level)% CRITICAL"
    }
    return "\(member.name): \(level)% OK"
}

print("--- Crew status ---")
for member in crew {
    print(status(of: member))
}

// 4.3 перелив кислорода
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    if amount <= 0 { return 0 }
    var actual = amount
    if actual > source       { actual = source }
    if actual > 100 - target { actual = 100 - target }
    source -= actual
    target += actual
    return actual
}

var s1 = 50, t1 = 80
let moved1 = transferOxygen(from: &s1, to: &t1, amount: 30)
print("Test 1: moved = \(moved1), source = \(s1), target = \(t1)")

var s2 = 5, t2 = 10
let moved2 = transferOxygen(from: &s2, to: &t2, amount: 30)
print("Test 2: moved = \(moved2), source = \(s2), target = \(t2)")

// фрагмент D - работаю на локальных копиях чтобы не портить реальные модули
var labLevel = lab.oxygenTank?.level ?? 0
var habLevel = hab.oxygenTank?.level ?? 0

let movedToHab = transferOxygen(from: &labLevel, to: &habLevel, amount: 30)

print("Transferred Lab -> Hab: \(movedToHab)")
print("Lab level (local): \(labLevel)")
print("Hab level (local): \(habLevel)")

let D = habLevel
print("D = \(D)")


// MARK: Level 5 - дневник саботажника
//
// оригинальный код
//   func reportOxygen(for member: CrewMember) -> String {
//       let tank = member.module!.oxygenTank!
//       return "\(member.name): \(tank.level)%"
//   }
//   func firstCritical(in crew: [CrewMember]) -> String {
//       var result: String?
//       for member in crew {
//           if oxygenLevel(of: member)! < 20 {
//               result = member.name
//           }
//       }
//       return result!
//   }
//
// БАГ 1 module! - если module nil (Nurlan) краш
// БАГ 2 oxygenTank! - если бака нет (Dana) краш
// БАГ 3 oxygenLevel(...)! - если nil (Dana Nurlan) краш
// БАГ 4 return result! - если никто не критичен краш
// БАГ 5 логический - result перезаписывается каждый раз
//        возвращает ПОСЛЕДНЕГО а не первого

func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let place = member.module?.name ?? "open space"
        return "\(member.name): no data (\(place))"
    }
    return "\(member.name): \(level)%"
}

// теперь String? и возвращает первого критического
func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

// тесты на чистых копиях
let labClean  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let habClean  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dockClean = Module(name: "Dock", oxygenTank: nil)

let timurClean  = CrewMember(name: "Timur",  role: "Engineer",  priority: 3, module: labClean)
let danaClean   = CrewMember(name: "Dana",   role: "Scientist", priority: 4, module: dockClean)
let nurlanClean = CrewMember(name: "Nurlan", role: "Pilot",     priority: 2, module: nil)

print("reportOxygen(Timur):  \(reportOxygen(for: timurClean))")
print("reportOxygen(Dana):   \(reportOxygen(for: danaClean))")
print("reportOxygen(Nurlan): \(reportOxygen(for: nurlanClean))")

// на стартовых данных баг не видно
print("firstCritical(starter) = \(firstCritical(in: crew) ?? "nil")")

// тест который доказывает что баг исправлен
let badHab        = Module(name: "Hab", oxygenTank: Tank(level: 5))
let timurCritical = CrewMember(name: "Timur", role: "Engineer", priority: 3, module: badHab)
let aigerimCritical = crew[2]

let testCrew = [timurCritical, aigerimCritical]
let first = firstCritical(in: testCrew)
print("firstCritical(2 criticals) = \(first ?? "nil")")
print("Логический баг исправлен: \(first == "Timur")")


// MARK: Финал - код запуска

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// MARK: - ================= ВОПРОСЫ НА ЗАЩИТУ =================
/*
 1 чем guard let отличается от if let

    guard let выходит из функции сразу если nil и дальше идёт обычный
    код без вложенности а if let оставляет вложенный блок и код уезжает
    вправо

    пример где if let хуже - три опционала подряд получится пирамидка
        if let a = optA {
            if let b = optB {
                if let c = optC {
                    // логика
                }
            }
        }
    а с guard плоско
        guard let a = optA, let b = optB, let c = optC else { return nil }
        // логика

 2 почему нельзя передать [Int] в stats(_ values: Int...)

    потому что Int... это НЕ [Int] на уровне вызова
    компилятор ждёт список отдельных аргументов (stats(1, 2, 3)) и сам
    упаковывает их в массив ВНУТРИ функции
    для массива нужна отдельная перегрузка stats(of:) она у меня есть

 3 почему transferOxygen(from: &x, to: &x, amount: 5) не компилируется

    два inout параметра не могут ссылаться на одну переменную
    это exclusive access в Swift
    если бы разрешили функция читала бы и писала в одну память
    и непонятно что куда прибавилось
    компилятор это запрещает чтобы не было таких багов

 4 почему oxygenLevel(of: dana) ?? "no data" не компилируется

    ?? требует чтобы слева был Optional<T> а справа T
    oxygenLevel возвращает Int? а "no data" это String типы не совпадают
    сначала надо Int? превратить в String?
        if let level = oxygenLevel(of: dana) {
            return "\(level)%"
        } else {
            return "no data"
        }

 5 какой полный тип у chooseProtocol

        (Int) -> ((Int) -> Int)

    функция которая принимает Int и возвращает функцию которая
    принимает Int и возвращает Int
    первая стрелка это сам chooseProtocol
    вторая это то что он возвращает (heatUp/coolDown/hold)

 Bonus где живёт счётчик после возврата из makeAlarm

    в захваченной переменной внутри замыкания
    когда makeAlarm возвращается Swift переносит захваченные переменные
    в heap они живут пока живо само замыкание
    counter существует пока переменная alarm держит замыкание
*/


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var counter = 0
    return { level in
        if level < threshold {
            counter += 1
            print("Alarm #\(counter)")
            return true
        }
        return false
    }
}

let alarm = makeAlarm(threshold: 20)
print("alarm(12) = \(alarm(12))")
print("alarm(40) = \(alarm(40))")
print("alarm(5)  = \(alarm(5))")
