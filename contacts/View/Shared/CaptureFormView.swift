//
//  CaptureFormView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//      changes should be rare; it is recommended changes are applied to the template
//      and the entire file compared-and-then-replaced here if/as appropriate
//
//      Template v0.1.2 (renamed from TextCaptureSectionView)
//


import Foundation
import SwiftUI

struct CaptureFormView<T: Listable>: View {
    @ObservedObject var viewModel: CaptureFormViewModel<T>
    var showHeader: Bool = true

    @FocusState private var focusedFieldIndex: Int?

    private func nextField() {
        let nextIndex = (focusedFieldIndex ?? -1) + 1
        if nextIndex < viewModel.fields.count {
            focusedFieldIndex = nextIndex
        } else {
            if viewModel.isValid { viewModel.insert() }
            focusedFieldIndex = 0
        }
    }

    var body: some View {
        Section(header: showHeader ? Text(viewModel.title) : nil) {
            ForEach(viewModel.fields.indices, id: \.self) { i in
                displayLabeledTextField(atIndex: i)
            }

            Button("Submit") {
                viewModel.insert()
            }
            .disabled(!viewModel.isValid)
        }
    }

    private func displayLabeledTextField(atIndex i: Int) -> some View {
        LabeledContent {
            TextField(
                viewModel.fields[i].promptText,
                text: Binding(
                    get: { viewModel.fields[i].text },
                    set: { viewModel.fields[i].text = $0 }
                )
            )
            .textInputAutocapitalization(viewModel.fields[i].autoCapitalize ? .words : .never)
            .disableAutocorrection(true)
            .focused($focusedFieldIndex, equals: i)
            .onTapGesture { focusedFieldIndex = i }
            .onSubmit { nextField() }
        } label: {
            Text(viewModel.fields[i].labelText)
        }
        .labeledContentStyle(TopLabeledContentStyle())
    }
}


#if DEBUG
#Preview {
    Form {
        CaptureFormView(
            viewModel: TemplateStruct.makeCaptureFormViewModel(store: ListableFileStore<TemplateStruct>())
        )
    }
    .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#endif
