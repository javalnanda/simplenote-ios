import UIKit

// MARK: - PinLockViewController
//
class PinLockViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var progressView: PinLockProgressView!
    @IBOutlet private weak var headerStackView: UIStackView!
    @IBOutlet private var keypadButtons: [UIButton] = []

    private let controller: PinLockController
    private var inputValues: [Int] = [] {
        didSet {
            progressView.progress = inputValues.count
            updateCancelButton()
        }
    }

    init(controller: PinLockController) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        controller.configurationObserver = { [weak self] (configuration, animation) in
            self?.update(with: configuration, animation: animation)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        controller.configurationObserver = nil
    }
}

// MARK: - Setup
//
private extension PinLockViewController {
    func setup() {
        view.backgroundColor = .simplenoteLockScreenBackgroudColor
        setupMessageLabel()
        setupCancelButton()
        setupProgressView()
        setupKeypadButtons()
    }

    func setupCancelButton() {
        cancelButton.setTitleColor(.white, for: .normal)
        updateCancelButton()
    }

    func setupProgressView() {
        progressView.length = Constants.pinLength
    }

    func setupKeypadButtons() {
        for button in keypadButtons {
            button.setBackgroundImage(UIColor.simplenoteLockScreenButtonColor.dynamicImageRepresentation(), for: .normal)
            button.setBackgroundImage(UIColor.simplenoteLockScreenHighlightedButtonColor.dynamicImageRepresentation(), for: .highlighted)
            button.addTarget(self, action: #selector(handleTapOnKeypadButton(_:)), for: .touchUpInside)
        }
    }

    func setupMessageLabel() {
        messageLabel.textColor = .simplenoteLockScreenMessageColor
    }

    func update(with configuration: PinLockControllerConfiguration, animation: UIView.ReloadAnimation?) {
        guard let animation = animation else {
            update(with: configuration)
            return
        }

        headerStackView.reload(with: animation, in: view) { [weak self] in
            self?.update(with: configuration)
        }
    }

    func update(with configuration: PinLockControllerConfiguration) {
        inputValues = []
        updateTitleLabel(with: configuration)
        updateMessageLabel(with: configuration)
    }

    func updateTitleLabel(with configuration: PinLockControllerConfiguration) {
        titleLabel.text = configuration.title
    }

    func updateMessageLabel(with configuration: PinLockControllerConfiguration) {
        // Use `space` to preserve the height of `messageLabel` even if it's empty
        let text = configuration.message ?? " "
        messageLabel.text = text
    }

    func updateCancelButton() {
        if inputValues.isEmpty {
            cancelButton.setTitle(Localization.cancelButton, for: .normal)
            cancelButton.isHidden = !controller.isCancellable
            return
        }

        cancelButton.isHidden = false
        cancelButton.setTitle(Localization.deleteButton, for: .normal)
    }
}

// MARK: - Pincode
//
private extension PinLockViewController {
    func addDigit(_ digit: Int) {
        guard inputValues.count < Constants.pinLength else {
            return
        }

        inputValues.append(digit)

        if inputValues.count == Constants.pinLength {
            let pin = inputValues.compactMap(String.init).joined()
            controller.handlePin(pin)
        }
    }

    func removeLastDigit() {
        guard !inputValues.isEmpty else {
            return
        }

        inputValues.removeLast()
    }
}

// MARK: - Buttons
//
private extension PinLockViewController {
    @objc
    func handleTapOnKeypadButton(_ button: UIButton) {
        guard let index = keypadButtons.firstIndex(of: button) else {
            return
        }

        addDigit(index)

    }

    @IBAction
    private func handleTapOnCancelButton() {
        removeLastDigit()
    }
}

// MARK: - External keyboard
//
extension PinLockViewController {
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var keyCommands: [UIKeyCommand]? {
        var commands = (0..<10).map {
            UIKeyCommand(input: String($0), modifierFlags: [], action: #selector(handleKeypress(_:)))
        }

        let backspaceCommand = UIKeyCommand(input: "\u{8}", modifierFlags: [], action: #selector(handleBackspace))
        commands.append(backspaceCommand)

        return commands
    }

    @objc
    private func handleKeypress(_ keyCommand: UIKeyCommand) {
        guard let digit = Int(keyCommand.input ?? "") else {
            return
        }

        addDigit(digit)
    }

    @objc
    private func handleBackspace() {
        removeLastDigit()
    }
}

// MARK: - Localization
//
private enum Localization {

    static let enterYourPasscode = NSLocalizedString("Enter your passcode", comment: "Title on the PinLock screen asking to enter a passcode")
    static let deleteButton = NSLocalizedString("Delete", comment: "PinLock screen \"delete\" button")
    static let cancelButton = NSLocalizedString("Cancel", comment: "PinLock screen \"cancel\" button")
}

// MARK: - Constants
//
private enum Constants {
    static let pinLength: Int = 4
}
