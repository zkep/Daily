//
//  ToastMessage.swift
//  Daily
//
//  Created by kasoly on 2022/4/10.
//

import SwiftUI

extension View {
    
    public func present<MessageContent: View>(
        isPresented: Binding<Bool>,
        type: MessageView<MessageContent>.MessageType = .alert,
        position: MessageView<MessageContent>.Position = .bottom,
        animation: Animation = Animation.easeOut(duration: 0.3),
        autohideDuration: Double? = 3.0,
        closeOnTap: Bool = true,
        onTap: (() -> Void)? = nil,
        closeOnTapOutside: Bool = false,
        view: @escaping () -> MessageContent) -> some View {
        self.modifier(
            MessageView(
                isPresented: isPresented,
                type: type,
                position: position,
                animation: animation,
                autohideDuration: autohideDuration,
                closeOnTap: closeOnTap,
                onTap: onTap ?? {},
                closeOnTapOutside: closeOnTapOutside,
                view: view)
        )
    }
    
    func applyIf<T: View>(_ condition: @autoclosure () -> Bool, apply: (Self) -> T) -> AnyView {
        if condition() {
            return AnyView(apply(self))
        } else {
            return AnyView(self)
        }
    }
}



public struct MessageView<MessageContent>: ViewModifier where MessageContent: View {
    
    public enum MessageType {
        
        case alert
        case toast
        case floater(verticalPadding: CGFloat = 50)
        
        func shouldBeCentered() -> Bool {
            switch self {
                case .alert:
                    return true
                default:
                    return false
            }
        }
    }
    
    public enum Position {
        
        case top
        case bottom
    }
    
    // MARK: - Public Properties
    
    /// Tells if the sheet should be presented or not
    @Binding var isPresented: Bool
    
    var type: MessageType
    var position: Position
    
    var animation: Animation
    
    /// If nil - never hides on its own
    var autohideDuration: Double?
    
    /// Should close on tap - default is `true`
    var closeOnTap: Bool
    
    /// Allow to perform action on tap default is
    var onTap: () -> Void
    
    /// Should close on tap outside - default is `false`
    var closeOnTapOutside: Bool
    
    var view: () -> MessageContent
    
    /// holder for autohiding dispatch work (to be able to cancel it when needed)
    var dispatchWorkHolder = DispatchWorkHolder()
    
    // MARK: - Private Properties
    
    /// The rect of the hosting controller
    @State private var presenterContentRect: CGRect = .zero
    
    /// The rect of popup content
    @State private var sheetContentRect: CGRect = .zero
    
    /// The offset when the popup is displayed
    private var displayedOffset: CGFloat {
        switch type {
            case .alert:
                return  -presenterContentRect.midY + screenHeight/2
            case .toast:
                if position == .bottom {
                    return screenHeight - presenterContentRect.midY - sheetContentRect.height/2
                } else {
                    return -presenterContentRect.midY + sheetContentRect.height/2
            }
            case .floater(let verticalPadding):
                if position == .bottom {
                    return screenHeight - presenterContentRect.midY - sheetContentRect.height/2 - verticalPadding
                } else {
                    return -presenterContentRect.midY + sheetContentRect.height/2 + verticalPadding
            }
        }
    }
    
    /// The offset when the popup is hidden
    private var hiddenOffset: CGFloat {
        if position == .top {
            if presenterContentRect.isEmpty {
                return -1000
            }
            return -presenterContentRect.midY - sheetContentRect.height/2 - 5
        } else {
            if presenterContentRect.isEmpty {
                return 1000
            }
            return screenHeight - presenterContentRect.midY + sheetContentRect.height/2 + 5
        }
    }
    
    /// The current offset, based on the **presented** property
    private var currentOffset: CGFloat {
        return isPresented ? displayedOffset : hiddenOffset
    }
    
    private var screenHeight: CGFloat {
        #if os(watchOS)
        return WKInterfaceDevice.current().screenBounds.size.height
        #elseif os(iOS)
        return UIScreen.main.bounds.size.height
        #elseif os(macOS)
        return NSScreen.main?.frame.height ?? 0
        #endif
    }
    
    private var screenWidth: CGFloat {
        #if os(watchOS)
        return WKInterfaceDevice.current().screenBounds.size.width
        #elseif os(iOS)
        return UIScreen.main.bounds.size.width
        #elseif os(macOS)
        return NSScreen.main?.frame.width ?? 0
        #endif
    }
    
    // MARK: - Content Builders
    
    public func body(content: Content) -> some View {
        content
            .applyIf(closeOnTapOutside) {
                $0.simultaneousGesture( TapGesture().onEnded {
                    self.isPresented = false
                })
        }
        .background(
            GeometryReader { proxy -> AnyView in
                let rect = proxy.frame(in: .global)
                if rect.integral != self.presenterContentRect.integral {
                    DispatchQueue.main.async {
                        self.presenterContentRect = rect
                    }
                }
                return AnyView(EmptyView())
            }
        ).overlay(presentSheet())
    }
    
    /// This is the builder for the sheet content
    func presentSheet() -> some View {
        
        // if needed, dispatch autohide and cancel previous one
        if let autohideDuration = autohideDuration {
            dispatchWorkHolder.work?.cancel()
            dispatchWorkHolder.work = DispatchWorkItem(block: {
                self.isPresented = false
            })
            if isPresented, let work = dispatchWorkHolder.work {
                DispatchQueue.main.asyncAfter(deadline: .now() + autohideDuration, execute: work)
            }
        }
        
        return ZStack {
            Group {
                withAnimation(animation) {
                    VStack {
                        VStack {
                            self.view()
                                .simultaneousGesture(TapGesture().onEnded {
                                    if self.closeOnTap {
                                        self.isPresented = false
                                        self.onTap()
                                    }
                                })
                                .background(
                                    GeometryReader { proxy -> AnyView in
                                      let rect = proxy.frame(in: .global)
                                      if rect.integral != self.sheetContentRect.integral {
                                        DispatchQueue.main.async {
                                             self.sheetContentRect = rect
                                        }
                                      }
                                      return  AnyView(EmptyView())
                                  }
                              )
                         }
                    }
                    .frame(width: screenWidth)
                    .offset(x: 0, y: currentOffset)
                }
            }
        }
    }
}


class DispatchWorkHolder {
    var work: DispatchWorkItem?
}
