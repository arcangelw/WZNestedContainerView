//
//  ListSectionFooterRefreshController.swift
//  Example
//
//  Created by 吴哲 on 2024/3/5.
//

import MJRefresh
import NestedContainerView
import UIKit

// swiftlint:disable:next line_length
final class ListSectionFooterRefreshController: HorizontalNestedContentSectionController, UITableViewDataSource, UITableViewDelegate {
    private lazy var header = SectionEditHeader()
    private lazy var footer = SectionFooter()

    let content = SingleNestedContentView(UITableView(frame: .zero, style: .plain))

    var listCount = 10

    var showHeader: Bool = true

    var showFooter: Bool = true

    override init() {
        super.init()
        management = content
        content.backgroundColor = .lightGray
        content.embeddedScrollView.contentInsetAdjustmentBehavior = .never
        content.embeddedScrollView.rowHeight = 44
        content.embeddedScrollView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        content.embeddedScrollView.delegate = self
        content.embeddedScrollView.dataSource = self
        content.embeddedScrollView.showsVerticalScrollIndicator = false
        header.action = { [weak self] in
            self?.reload()
        }
        self.showFooter = false
        let footer = MJRefreshAutoNormalFooter()
        footer.refreshingBlock = { [weak self] in
            self?.loadMore()
        }
        content.embeddedScrollView.mj_footer = footer
    }

    private func loadMore() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.listCount += 10
            self.content.embeddedScrollView.reloadData()
            self.content.embeddedScrollView.mj_footer?.endRefreshing()
        }
    }

    @objc
    private func reload() {
        listCount = [5, 15, 30].randomElement()!
        content.embeddedScrollView.reloadData()
    }

    var observer: NSKeyValueObservation?

    override func sectionDidChange() {
        header.section = section
        footer.section = section
        content.embeddedScrollView.reloadData()
        observer = content.embeddedScrollView.observe(\.contentSize, options: .new) { [weak self] _, _ in
            guard let self = self else { return }
            self.containerContext?.invalidateLayout(in: self, completion: nil)
        }
    }

    override func sectionHeaderView() -> UIView? {
        return showHeader ? header : nil
    }

    override func sectionHeaderHeight() -> CGFloat {
        return showHeader ? 30 : 0
    }

    override func sectionContentView() -> UIView {
        return content
    }

    override func sectionEmbeddedScrollView() -> UIScrollView? {
        return content.embeddedScrollView
    }

    override func sectionContentHeightMode() -> NestedSectionContentHeightMode {
        return .embedded(.filled, embeddedContentHeight: content.embeddedScrollView.contentSize.height)
    }

    override func sectionFooterView() -> UIView? {
        return showFooter ? footer : nil
    }

    override func sectionFooterHeight() -> CGFloat {
        return showFooter ? 30 : 0
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return listCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "ListSection: \(section), cell row: \(indexPath.row) "
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        embeddedScrollViewEvent(.didScroll(scrollView))
    }
}
