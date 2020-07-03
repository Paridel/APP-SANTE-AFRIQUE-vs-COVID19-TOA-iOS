//
// Created by Nickolay Sheika on 6/13/16.
//

import Foundation
import QuartzCore
import UIKit


extension UIView {

    private struct RuntimePropertiesKeys {
        static var StoredAnimationsKey = "StoredAnimationsKey"
    }

    private var storedAnimations: [String:CAAnimation]? {
        set {
            setAssociatedObject(self,
                                value: newValue,
                                associativeKey: &RuntimePropertiesKeys.StoredAnimationsKey,
                                policy: objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return getAssociatedObject(self, associativeKey: &RuntimePropertiesKeys.StoredAnimationsKey)
        }
    }

    // MARK: - Public

    func backupAnimations() {
        storedAnimations = currentAnimationsOnLayer(layer)
    }

    func restoreAnimations() {
        guard let storedAnimations = storedAnimations else  {
            return
        }

        layer.removeAllAnimations()
        restoreAnimationsOnLayer(layer, animations: storedAnimations)
        self.storedAnimations = nil
    }

    // MARK: - Private

    private func currentAnimationsOnLayer(layer: CALayer) -> [String:CAAnimation] {
        let animationKeys = layer.animationKeys()

        if animationKeys != nil && animationKeys!.count > 0 {
            var currentAnimations = [String: CAAnimation]()
            for key in animationKeys! {
                let animation = layer.animationForKey(key)!.copy() as! CAAnimation
                currentAnimations[key] = animation
            }
            return currentAnimations
        }
        return [:]
    }

    private func restoreAnimationsOnLayer(layer: CALayer, animations: [String:CAAnimation]) {
        for (key, value) in animations {
            layer.addAnimation(value, forKey: key)
        }
    }
}