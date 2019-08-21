//
//  TableViewWidget.swift
//  RxSwiftWidgets
//
//  Created by Michael Long on 7/10/19.
//  Copyright © 2019 Michael Long. All rights reserved.
//


import UIKit
import RxSwift
import RxCocoa

//public class TableViewTest {
//
//    @State var items: [String] = []
//
//    func builder() -> Widget {
//        return TableViewWidget([
//            SectionWidget([
//                LabelWidget("Section 1 Row 1"),
//                LabelWidget("Section 1 Row 2"),
//                LabelWidget("Section 1 Row 2")
//            ]),
//            SectionWidget([
//                LabelWidget("Section 2 Row 1"),
//                LabelWidget("Section 2 Row 2")
//            ]),
//            DynamicSectionWidget<String>($items) {
//                LabelWidget($0)
//            }
//        ])
//
//    }
//}

public protocol WidgetUpdatable: class {
    func updated()
}

public protocol TableViewCellProviding {
    func cell(for tableView: UITableView, with context: WidgetContext) -> UITableViewCell
}

public class TableViewWidget
    : NSObject
    , Widget
    , WidgetViewModifying
    , WidgetPadding
    , WidgetUpdatable {

    public override var debugDescription: String { "TableViewWidget()" }

    public weak var tableView: UITableView!

    public var sections: [SectionWidget]

    public var modifiers = WidgetModifiers()
    public var context: WidgetContext!

    public var grouped: UITableView.Style?

    public init(_ sections: [SectionWidget] = []) {
        self.sections = sections
        super.init()
        sections.forEach { $0.parent = self }
    }

    public func build(with context: WidgetContext) -> UIView {

        let grouped = self.grouped ?? (sections.count > 1 ? .grouped : .plain)

        let view = WidgetTableView(frame: .zero, style: grouped)
        self.context = modifiers.modified(context, for: view)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.insetsLayoutMarginsFromSafeArea = false
        
        view.tableViewWidget = self
        view.dataSource = self
        view.register(WidgetTableViewCell.self, forCellReuseIdentifier: "WidgetCell")

        if #available(iOS 11.0, *) {
            view.insetsContentViewsToSafeArea = false
        } // kill default behavior and left safearea modifier handle things.

        modifiers.apply(to: view, with: self.context)

        self.tableView = view

        return view
    }

    public func with(_ block: @escaping WidgetModifierBlockType<UITableView>) -> Self {
        return modified(WidgetModifierBlock(block))
    }

    public func updated() {
        tableView?.reloadData()
    }

}

extension TableViewWidget: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard sections.indices.contains(section) else { return 0 }
        return sections[section].count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].cell(for: tableView, at: indexPath.row, with: context)
    }

}

fileprivate class WidgetTableView: UITableView {

    public var tableViewWidget: TableViewWidget?

}

open class WidgetTableViewCell: UITableViewCell {

    var disposeBag = DisposeBag()

    override open func prepareForReuse() {
        disposeBag = DisposeBag()
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }

    open func reset(_ widget: Widget, with context: WidgetContext, padding: UIEdgeInsets) {
        var context = context
        context.disposeBag = disposeBag
        let view = widget.build(with: context)
        contentView.addConstrainedSubview(view, with: padding)
    }

}
