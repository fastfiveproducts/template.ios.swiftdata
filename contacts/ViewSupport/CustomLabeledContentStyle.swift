//
//  CustomLabeledContentStyle.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//      changes should be rare; it is recommended changes are applied to the template
//      and the entire file compared-and-then-replaced here if/as appropriate
//
//      Template v0.1.2 (revisions)
//


import SwiftUI

// custom Text Field LabeledContentStyle, 'Top Labeled':
struct TopLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .font(.caption)
            configuration.content
        }
    }
}

#if DEBUG
fileprivate struct TopLabelLabeledContentStylePreview: View {
    var labelText: String
    var promptText: String
    var text: Binding<String>
    @FocusState private var focusedFieldIndex: Int?
    var body: some View {
        LabeledContent {
            TextField(promptText, text:text)
                .textInputAutocapitalization(TextInputAutocapitalization.words)
                .disableAutocorrection(true)
                .onSubmit {}
                .focused($focusedFieldIndex, equals: 0)
        } label: { Text(labelText) }
            .labeledContentStyle(TopLabeledContentStyle())
    }
}


#Preview ("TopLabelLabeledContentStyle") {
    Form {
        Section {
            TopLabelLabeledContentStylePreview(
                labelText: "Your Name",
                promptText: "Name or Intitials",
                text: .constant(""))
            TopLabelLabeledContentStylePreview(
                labelText: "More Stuff",
                promptText: "stuff we want to know",
                text: .constant(""))
        }
    }
    .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
}
#endif
