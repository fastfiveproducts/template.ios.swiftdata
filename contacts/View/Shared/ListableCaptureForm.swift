//
//  ListableCaptureForm.swift
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

struct ListableCaptureForm<T: Listable>: View {
    @ObservedObject var viewModel: ListableCaptureFormModel<T>
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
        Form {
            Section(header: showHeader ? Text(viewModel.title) : nil) {
                ForEach(viewModel.fields.indices, id: \.self) { i in
                    displayCaptureField(atIndex: i)
                }
                
                Button("Submit") {
                    viewModel.insert()
                }
                .disabled(!viewModel.isValid)
            }
        }
    }

    private func displayCaptureField(atIndex i: Int) -> some View {
        return LabeledContent {
            if viewModel.fields[i].type == .bool {
                HStack {
                    Text(viewModel.fields[i].promptText)
                    Spacer()
                    Button {
                        viewModel.fields[i].bool.toggle()
                    } label: {
                        Image(systemName: viewModel.fields[i].bool ? "checkmark.circle.fill" : "circle")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .accessibilityLabel("\(viewModel.fields[i].promptText) is \(viewModel.fields[i].bool ? "Yes" : "No")")
                }
                .focused($focusedFieldIndex, equals: i)
                .onTapGesture { focusedFieldIndex = i }
                .onSubmit { nextField() }
            }
            if viewModel.fields[i].type == .text {
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
            }
        } label: {
            Text(viewModel.fields[i].labelText)
        }
        .labeledContentStyle(TopLabeledContentStyle())
    }
}


#if DEBUG
#Preview {
    ListableCaptureForm(
        viewModel: Location.makeCaptureFormViewModel(store: ListableFileStore<Location>())
    )
    .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#endif
