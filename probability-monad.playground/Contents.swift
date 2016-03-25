
import Foundation

protocol Stochastic {
    // the type of value stored in the distribution
    associatedtype ValueType
    
    // Sample a single value from the distribution
    func get() -> ValueType
    
    // Sample n values from the distribution
    func sample(n: Int) -> [ValueType]
}

protocol Parameterized {
    associatedtype ParameterType
    var p: ParameterType { get }
}

protocol Transformable {
    associatedtype A
    associatedtype B
    
    // function that maps A to B
    var f: A -> B { get set }
    
    // function that resets the function f
//    mutating func map(a: A) -> B
}

//let x = 9
//x
//
struct Distribution<A> {
//    var generator: T -> A
    var get: () -> A
    
//    func get() -> A {
//        return
//    }
    
    func map<B>(generator: () -> B, f: A -> B) -> Distribution<B> {
        var d = Distribution<B>(get: generator)
        d.get = {
            (Void) -> B in return f(self.get())
        }
        return d
    }
}

let u = Distribution<Double>(get: {(Void) -> Double in return drand48()})
u.get()
u.get()
u.get()

let u2 = u.map(u.get, f: {(x: Double) in return x + 10})
u2.get()


//u.map({(x: Bool) -> Bool in return x}, f: {(p: Double, x: Double) -> Bool in return x < p})

//let tfGenerator = {(p: Double, x: Double) -> Bool in return x < p}
//tfGenerator(p: 0.5)



//
//let dist = Distribution<String>(x: "a")
//print(dist.x)


struct UniformDoubleDist: Stochastic, Transformable {
    // identity function
    var f = {(x: Double) -> Double in return x}
    
    
    // Returns a uniform double on [0,1]
    func get() -> Double {
        return self.f(drand48())
    }
    
    func sample(n: Int) -> [Double] {
        return (1...n).map { x in get() }
    }
    
    
}

let uniform = UniformDoubleDist()
uniform.get()
uniform.sample(2)


struct BooleanDist: Stochastic, Parameterized, Transformable {
    var p: Double
    
    // identity function
    var f = {(x: Bool) -> Bool in return x}
    
    let uniform = UniformDoubleDist()
    
    init(p: Double) {
        self.p = p
    }
    
    func get() -> Bool {
        return self.f(uniform.get() < p)
    }
    
    func sample(n: Int) -> [Bool] {
        return uniform.sample(n).map { x in x < p }
    }
}

let tf = BooleanDist(p: 0.8)
tf.sample(10)


struct BernoulliDist: Stochastic, Parameterized {
    var p: Double
    let uniform = UniformDoubleDist()
    
    func get() -> Int {
        return oneOrZero(uniform.get() < p)
    }
    
    func sample(n: Int) -> [Int] {
        return uniform.sample(n).map { x in x < p }.map { x in oneOrZero(x) }
    }
        
    private func oneOrZero(x: Bool) -> Int {
        if (x) {
            return 1
        } else {
            return 0
        }
    }
}

let bernoulli = BernoulliDist(p: 0.5)
bernoulli.sample(10)

