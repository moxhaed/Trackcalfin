import Flutter
import SwiftUI
import UIKit

/// The bottom navigation in native Liquid Glass (iOS 26+): a glass capsule of
/// tabs and a tinted glass capture button beside it. Flutter embeds it as a
/// platform view (`lib/app/floating_nav.dart`) and owns the navigation state;
/// this view mirrors it and reports taps back.
///
/// SwiftUI rather than a standalone `UITabBar`: since iOS 26 that bar sizes and
/// places its glass platter privately, so it can't fill a Flutter-sized frame.
@available(iOS 26.0, *)
final class GlassNavFactory: NSObject, FlutterPlatformViewFactory {
  static let viewType = "trackcalfin/glass-nav"

  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    GlassNavView(frame: frame, viewId: viewId, args: args as? [String: Any] ?? [:], messenger: messenger)
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

@available(iOS 26.0, *)
final class GlassNavView: NSObject, FlutterPlatformView {
  private let model: GlassNavModel
  private let host: UIHostingController<GlassNavBar>
  private let channel: FlutterMethodChannel

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    let tabs = (args["tabs"] as? [[String: Any]] ?? []).map {
      GlassNavModel.Tab(
        label: $0["label"] as? String ?? "",
        symbol: $0["symbol"] as? String ?? "",
        activeSymbol: $0["activeSymbol"] as? String ?? ""
      )
    }
    model = GlassNavModel(tabs: tabs, captureLabel: args["captureLabel"] as? String ?? "")
    host = UIHostingController(rootView: GlassNavBar(model: model))
    channel = FlutterMethodChannel(name: "\(GlassNavFactory.viewType)/\(viewId)", binaryMessenger: messenger)
    super.init()

    host.view.frame = frame
    host.view.backgroundColor = .clear
    // Flutter already lifts the bar above the home indicator.
    host.safeAreaRegions = []
    model.onSelect = { [weak self] index in self?.channel.invokeMethod("select", arguments: index) }
    model.onCapture = { [weak self] in self?.channel.invokeMethod("capture", arguments: nil) }

    apply(args)
    channel.setMethodCallHandler { [weak self] call, result in
      if call.method == "update", let args = call.arguments as? [String: Any] {
        self?.apply(args)
      }
      result(nil)
    }
  }

  func view() -> UIView { host.view }

  /// Applies Flutter's state: selected index, badges and theme colors.
  private func apply(_ args: [String: Any]) {
    if let dark = args["dark"] as? Bool {
      host.overrideUserInterfaceStyle = dark ? .dark : .light
    }
    if let tint = args["tint"] as? Int {
      model.tint = Color(uiColor: UIColor(argb: tint))
    }
    if let onTint = args["onTint"] as? Int {
      model.onTint = Color(uiColor: UIColor(argb: onTint))
    }
    if let badges = args["badges"] as? [Int] {
      model.badges = badges
    }
    if let index = args["index"] as? Int {
      model.index = index
    }
  }
}

@available(iOS 26.0, *)
@Observable
final class GlassNavModel {
  struct Tab {
    let label: String
    let symbol: String
    let activeSymbol: String
  }

  let tabs: [Tab]
  let captureLabel: String
  var index = 0
  var badges: [Int] = []
  var tint = Color.accentColor
  var onTint = Color.white
  @ObservationIgnored var onSelect: (Int) -> Void = { _ in }
  @ObservationIgnored var onCapture: () -> Void = {}

  init(tabs: [Tab], captureLabel: String) {
    self.tabs = tabs
    self.captureLabel = captureLabel
  }

  func badge(_ index: Int) -> Int { badges.indices.contains(index) ? badges[index] : 0 }
}

@available(iOS 26.0, *)
struct GlassNavBar: View {
  let model: GlassNavModel
  @Namespace private var selection

  var body: some View {
    GlassEffectContainer(spacing: 0) {
      HStack(spacing: 10) {
        HStack(spacing: 0) {
          ForEach(model.tabs.indices, id: \.self, content: tab)
        }
        .background {
          // One capsule that slides to the selected tab. With a capsule per tab shown only
          // when selected, the old one faded out while the new one faded in, so the new tab
          // seemed to light up before the selection got there.
          Capsule()
            .fill(.primary.opacity(0.08))
            .matchedGeometryEffect(id: model.index, in: selection, isSource: false)
        }
        .padding(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassEffect(.regular.interactive(), in: .capsule)
        .animation(.snappy, value: model.index)

        Button(action: model.onCapture) {
          Image(systemName: "plus")
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(model.onTint)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .aspectRatio(1, contentMode: .fit)
        .glassEffect(.regular.tint(model.tint).interactive(), in: .circle)
        .accessibilityLabel(model.captureLabel)
      }
    }
  }

  private func tab(_ index: Int) -> some View {
    let tab = model.tabs[index]
    let selected = index == model.index
    let badge = model.badge(index)
    return Button {
      model.index = index
      model.onSelect(index)
    } label: {
      VStack(spacing: 2) {
        Image(systemName: selected ? tab.activeSymbol : tab.symbol)
          .font(.system(size: 19, weight: .medium))
          .contentTransition(.symbolEffect(.replace))
          .frame(height: 26)
          .overlay(alignment: .topTrailing) {
            if badge > 0 {
              Text("\(badge)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .frame(minWidth: 16, minHeight: 16)
                .background(.red, in: .capsule)
                .offset(x: 10, y: -4)
            }
          }
        Text(tab.label)
          .font(.system(size: 10, weight: selected ? .semibold : .medium))
          .lineLimit(1)
      }
      .foregroundStyle(selected ? model.tint : .primary)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .matchedGeometryEffect(id: index, in: selection)
      .contentShape(.capsule)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(tab.label)
    .accessibilityValue(badge > 0 ? "\(badge)" : "")
    .accessibilityAddTraits(selected ? .isSelected : [])
  }
}

private extension UIColor {
  /// A Flutter `Color.toARGB32()` value.
  convenience init(argb: Int) {
    self.init(
      red: CGFloat((argb >> 16) & 0xFF) / 255,
      green: CGFloat((argb >> 8) & 0xFF) / 255,
      blue: CGFloat(argb & 0xFF) / 255,
      alpha: CGFloat((argb >> 24) & 0xFF) / 255
    )
  }
}
