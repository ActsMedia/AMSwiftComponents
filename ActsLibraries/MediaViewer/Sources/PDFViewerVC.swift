//  PDFViewerVC.swift
//
//  Copyright © 2020 ActsMedia. All rights reserved.
//  Created by Paul Fechner
//
#if canImport(UIKit) && canImport(PDFKit)

import UIKit
import PDFKit
import UIWrappers

open class PDFViewerVC: UIViewController, PDFViewDelegate, URLUpdatable {

    public var loadingAction: (() -> ())?
    public var loadingFinishedAction: (() -> ())?

    public let pdfView: PDFView = PDFView()

    var currentDocument: PDFDocument? = nil {
        didSet {
            showPDF()
        }
    }

    //MARK: Setup
    open override func viewDidLoad() {
        super.viewDidLoad()
        addPDFView()
        setupPDFView()
    }

    private func addPDFView() {
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        view.addConstraints([
            view.leadingAnchor.constraint(equalTo: pdfView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: pdfView.trailingAnchor),
            view.topAnchor.constraint(equalTo: pdfView.topAnchor),
            view.bottomAnchor.constraint(equalTo: pdfView.bottomAnchor),
        ])
    }

    private func setupPDFView() {
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.delegate = self
    }

    //MARK: Update
    open func update(with url: URL) {
        loadingAction?()
        DispatchQueue.global().async { [weak self] in
            let newDocument = PDFDocument(url: url)
            DispatchQueue.main.async {
                self?.currentDocument = newDocument
            }
        }

    }

    //MARK: Loading

    public func loadPDF(with url: URL) {

        loadingAction?()

        DispatchQueue.global().async { [weak self] in
            do {
                let data = try Data(contentsOf: url)

                if let pdfDocument = PDFDocument(data: data) {
                    DispatchQueue.main.async {
                        self?.currentDocument = pdfDocument
                    }
                }
            } catch {
                print(error)
                self?.showError()
            }
        }
    }

    func showPDF() {
        guard let currentDocument = currentDocument else {
            return
        }
        pdfView.document = currentDocument
        pdfView.goToFirstPage(nil)
        if let currentPage = self.pdfView.currentPage {
            let firstPageBounds = currentPage.bounds(for: self.pdfView.displayBox)
            self.pdfView.go(to: CGRect(x: 0, y: firstPageBounds.height + 10, width: 1.0, height: 1.0), on: currentPage)
        }
        loadingFinishedAction?()
    }

    func showError() {
        let alert = UIAlertController(title: "Error", message: "Could not load PDF. Please try again", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (action) in
        }
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: { () -> Void in })
    }

    // This fixes some weird behavior (as of iOS 11) when rotating/resizing the PDF view.
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let sizeToFitFactor = pdfView.scaleFactorForSizeToFit
        let currentScale = pdfView.scaleFactor
        if sizeToFitFactor == currentScale {
            coordinator.animate(alongsideTransition: { _ in
            }) { _ in
                self.pdfView.scaleFactor = self.pdfView.scaleFactorForSizeToFit
                if let currentPage = self.pdfView.currentPage {
                    let firstPageBounds = currentPage.bounds(for: self.pdfView.displayBox)
                    self.pdfView.go(to: CGRect(x: 0, y: firstPageBounds.height + 10, width: 1.0, height: 1.0), on: currentPage)
                }
            }
        }
    }
}

#endif
