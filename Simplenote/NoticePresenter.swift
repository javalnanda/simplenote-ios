import UIKit

class NoticePresenter: KeyboardObservable {

    // MARK: Properties
    //
    var containerView = PassthruView(frame: .zero)
    var noticeView: NoticeView?
    var noticeBottomConstraint: NSLayoutConstraint?

    var isPresenting: Bool {
        noticeView != nil
    }
    private var keyboardVisible: Bool = false
    private var keyboardHeight: CGFloat = .zero
    private var keyboardFloats: Bool = false
    private var keyboardNotificationTokens: [Any]?


    // MARK: Lifecycle
    //
    deinit {
        stopListeningToKeyboardNotifications()
    }

    // MARK: Presenting/Dismissing Methods
    //
    func presentNoticeView(_ noticeView: NoticeView, completion: @escaping () -> Void) {
        guard let keyWindow = getKeyWindow() else {
            return
        }
        self.noticeView = noticeView

        containerView.addSubview(noticeView)
        keyWindow.addFillingSubview(containerView)

        noticeBottomConstraint = noticeView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: Constants.notificationStartingPosition)
        noticeBottomConstraint?.isActive = true
        noticeView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true

        containerView.layoutIfNeeded()
        displayNotificationView() {
            completion()
        }
    }

    private func displayNotificationView(completion: @escaping () -> Void) {
        guard let noticeView = noticeView else {
            return
        }

        noticeBottomConstraint?.constant = keyboardFloats ? Constants.notificationOnScreenPosition :  configureOnScreenConstraint()

        let delay = noticeView.handler == nil ? Times.waitShort : Times.waitLong

        UIView.animate(withDuration: Times.animationTime) {
            self.containerView.layoutIfNeeded()
        } completion: { (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                completion()
            }
        }
    }

    private func configureOnScreenConstraint() -> CGFloat {
        var constant = Constants.notificationOnScreenPosition

        if keyboardVisible {
            constant -= keyboardHeight
        }

        return constant
    }

    func dismissNotification(completion: @escaping () -> Void) {
        guard let noticeView = noticeView else {
            return
        }

        UIView.animate(withDuration: Times.animationTime) {
            noticeView.alpha = .zero
        } completion: { (_) in
            self.noticeView?.removeFromSuperview()
            self.containerView.removeFromSuperview()
            self.noticeView = nil
            completion()
        }
    }

    // MARK: Keyboard Obserbers
    //
    func keyboardDidChangeFrame(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?) {
        guard let endFrame = endFrame,
              let animationCurve = animationCurve,
              let animationDuration = animationDuration else {
            return
        }
        setStoredStates(frame: endFrame)
        animateNoticeToNewKeyboardLocation(frame: endFrame, curve: animationCurve, animationDuration: animationDuration)
    }

    func keyboardWillChangeFrame(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?) {
        guard let endFrame = endFrame,
              let animationCurve = animationCurve,
              let animationDuration = animationDuration else {
            return
        }
        setStoredStates(frame: endFrame)
        animateNoticeToNewKeyboardLocation(frame: endFrame, curve: animationCurve, animationDuration: animationDuration)
    }

    private func setStoredStates(frame: CGRect) {
        let windowFrame = getWindowFrame()
        keyboardVisible = frame.height != .zero
        keyboardHeight = frame.intersection(getWindowFrame()).height
        keyboardFloats = frame.maxY < windowFrame.height
    }
    private func animateNoticeToNewKeyboardLocation(frame: CGRect, curve: UInt, animationDuration: TimeInterval) {
        if !isPresenting {
            return
        }

        let animationOptions = UIView.AnimationOptions(arrayLiteral: .beginFromCurrentState, .init(rawValue: curve))

        noticeBottomConstraint?.constant = keyboardFloats ? Constants.notificationOnScreenPosition : configureOnScreenConstraint()
        UIView.animate(withDuration: animationDuration, delay: .zero, options: animationOptions) {
            self.containerView.layoutIfNeeded()
        }
    }

    func startListeningToKeyboardNotifications() {
        keyboardNotificationTokens = addKeyboardObservers()
    }

    func stopListeningToKeyboardNotifications() {
        guard let tokens = keyboardNotificationTokens else {
            return
        }

        removeKeyboardObservers(with: tokens)
        keyboardNotificationTokens = nil
    }
}


extension NoticePresenter {
    // Convenience method to fetch current key window
    //
    private func getKeyWindow() -> UIWindow? {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    }

    private func getWindowFrame() -> CGRect {
        return getKeyWindow()?.frame ?? .zero
    }
}

private struct Times {
    static let waitShort = 1.5
    static let waitLong = 2.75
    static let animationTime = TimeInterval(0.5)
    static let tapWait = TimeInterval(3)
}

private struct Constants {
    static let notificationBottomMargin = CGFloat(-150)
    static let notificationStartingPosition = CGFloat(100)
    static let notificationOnScreenPosition = CGFloat(-50)
}
