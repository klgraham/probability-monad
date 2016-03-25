
import Foundation

struct Distribution<A> {
    var get: () -> A?
    
    func sample(n: Int) -> [A] {
        return (1...n).map { x in get()! }
    }
    
    func map<B>(f: A -> B) -> Distribution<B> {
        var d = Distribution<B>(get: {() -> Optional<B> in return nil})
        d.get = {
            (Void) -> B in return f(self.get()!)
        }
        return d
    }
}

// random number generation functions

func randomDouble() -> Double {
    return Double(Double(arc4random()) / Double(UInt32.max))
}

// from https://www.hackingwithswift.com/read/35/2/generating-random-numbers-in-ios-8-and-earlier
func RandomInt(min min: Int, max: Int) -> Int {
    if max < min { return min }
    return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
}

let lessThan: Double -> (Double -> Bool) = { (x: Double) in return { (p: Double) in return x < p}
}

// transformation functions

func lessThan(p: Double) -> (Double -> Bool) {
    return { x in return x < p }
}

func oneOrZero(x: Bool) -> Int {
    return x ? 1 : 0
}

let u = Distribution<Double>(get: randomDouble)
u.get()
u.get()
u.get()

let u2 = u.map({(x: Double) in return x + 10})
u2.get()

let tf1 = u.map(lessThan(0.5))
tf1.get()
tf1.sample(5)

let bernoulli1 = tf1.map(oneOrZero)
bernoulli1.sample(10)
