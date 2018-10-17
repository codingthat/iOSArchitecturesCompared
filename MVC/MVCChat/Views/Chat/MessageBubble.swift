//
//  MessageBubble.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 15/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit
import Constraint

class MessageBubble: UIView {

    enum State {
        case sending
        case displaying
        case failed
    }

    private enum BubbleAlignment {
        case leading
        case trailing
    }

    var state: State = .displaying {
        didSet {
            switch state {
            case .sending:
                break
            case .displaying:
                break
            case .failed:
                break
            }
        }
    }

    private let largeBubbleOffset = CGFloat(40.0)
    private let smallBubbleOffset = CGFloat(8.0)

    private lazy var message: UILabel = {
        let message = UILabel()
        message.numberOfLines = 0
        message.font = UIFont.preferredFont(forTextStyle: .body)
        addSubview(message)
        return message
    }()

    private lazy var sent: UILabel = {
        let sent = UILabel()
        sent.font = UIFont.preferredFont(forTextStyle: .footnote)
        sent.textAlignment = .natural
        sent.textColor = UIColor.lightGray
        addSubview(sent)
        return sent
    }()

    private lazy var read: UILabel = {
        let read = UILabel()
        read.font = UIFont.preferredFont(forTextStyle: .footnote)
        read.textAlignment = .natural
        read.textColor = UIColor.white
        addSubview(read)
        return read
    }()

    private var leftOffset: NSLayoutConstraint?
    private var rightOffset: NSLayoutConstraint?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func configure(with message: Message) {
        self.message.text = message.message
        sent.text = sentText(from: message.state, and: message.sendDate)
        read.text = readText(from: message.state, and: message.sender)
        configure(sender: message.sender)
    }

    private func sentText(from state: Message.State, and sendDate: Date) -> String {
        switch state {
        case .sending: return "Sending..."
        case .sent, .read: return DateRenderer.string(from: sendDate)
        }
    }

    private func readText(from state: Message.State, and sender: Message.Sender) -> String {
        switch (state, sender) {
        case (.read, .user): return "✓"
        case (_, _): return ""
        }
    }

    private func configure(sender: Message.Sender) {
        switch sender {
        case .user:
            backgroundColor = UIColor.blue
            message.textColor = UIColor.white
            alignBubble(.trailing)
        case .other:
            backgroundColor = UIColor.groupTableViewBackground
            message.textColor = UIColor.darkGray
            alignBubble(.leading)
        }
    }

    private func alignBubble(_ alignment: BubbleAlignment) {
        switch alignment {
        case .leading:
            leftOffset?.constant = smallBubbleOffset
            rightOffset?.constant = -largeBubbleOffset
        case .trailing:
            leftOffset?.constant = largeBubbleOffset
            rightOffset?.constant = -smallBubbleOffset
        }
    }

    private func setup() {
        addConstraints()
        layer.cornerRadius = 8
        clipsToBounds = true
    }

    private func addConstraints() {
        message.attach(sides: [.top, .leading, .trailing], 8)
        sent
            .attach(sides: [.leading, .bottom], 8)
            .space(8, .below, message)
        read
            .attach(sides: [.bottom, .trailing], 8)
            .space(2, .trailing, sent)
            .space(8, .below, message)
            .setContentHuggingPriority(.required, for: .horizontal)
    }

    @discardableResult
    func attach(to superview: UIView) -> UIView {
        attach(sides: [.top, .bottom], 4)
        leftOffset = Constraint.attach(self, inside: superview, leading: smallBubbleOffset).first
        rightOffset = Constraint.attach(self, inside: superview, trailing: smallBubbleOffset).first
        leftOffset?.isActive = true
        rightOffset?.isActive = true
        return self
    }

}
