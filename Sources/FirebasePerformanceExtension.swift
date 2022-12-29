/*
 Author Siarhei Ladzeika

 MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */
import UIKit
import ObjectiveC

fileprivate var _FPRScreenTraceTrackerShouldIgnore = 0

extension UIViewController {

    public var fpr_ShouldIgnoreScreenTrace: Bool {
        get {
            (objc_getAssociatedObject(self, &_FPRScreenTraceTrackerShouldIgnore) as? NSNumber)?.boolValue ?? false
        }
        set {
            objc_setAssociatedObject(self, &_FPRScreenTraceTrackerShouldIgnore, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public class FirebasePerformanceExtension {

    //
    // FPRScreenTraceTracker
    //  - (BOOL)shouldCreateScreenTraceForViewController:(UIViewController *)viewController
    //
    private static let shouldCreateScreenTraceForViewControllerSelector = NSSelectorFromString("shouldCreateScreenTraceForViewController:")

    private typealias ShouldCreateScreenTraceForViewControllerFunction = @convention(c) (AnyObject, Selector, UIViewController) -> Bool
    private typealias ShouldCreateScreenTraceForViewControllerBlock = @convention(block) (AnyObject, UIViewController) -> Bool

    private static func swizzleShouldCreateScreenTraceForViewControllerSelector(with block: @escaping ShouldCreateScreenTraceForViewControllerBlock) -> IMP? {

        guard let class_ = NSClassFromString("FPRScreenTraceTracker") else {
            return nil
        }

        let method: Method? = class_getInstanceMethod(class_, self.shouldCreateScreenTraceForViewControllerSelector)
        let newImplementation: IMP = imp_implementationWithBlock(unsafeBitCast(block, to: AnyObject.self))

        if let method = method {
            let oldImplementation: IMP = method_getImplementation(method)
            method_setImplementation(method, newImplementation)
            return oldImplementation
        } else {
            // NOTE: do not call class_addMethod...
            return nil
        }
    }

    public static func setup() {

        var oldImplementation: IMP?

        let swizzledBlock: ShouldCreateScreenTraceForViewControllerBlock = { obj, viewController in

            var result: Bool = true

            if let implementation = oldImplementation {
                let originalFunc: ShouldCreateScreenTraceForViewControllerFunction = unsafeBitCast(implementation,
                                                                                                   to: ShouldCreateScreenTraceForViewControllerFunction.self)
                result = originalFunc(obj, self.shouldCreateScreenTraceForViewControllerSelector, viewController)
            }

            if result && viewController.fpr_ShouldIgnoreScreenTrace {
                result = false
            }

            return result
        }

        oldImplementation = swizzleShouldCreateScreenTraceForViewControllerSelector(with: swizzledBlock)
    }
}
