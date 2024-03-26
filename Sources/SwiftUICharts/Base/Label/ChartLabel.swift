import SwiftUI
#if !os(macOS)
import UIKit
#endif

/// What kind of label - this affects color, size, position of the label
public enum ChartLabelType {
    case title
    case subTitle
    case largeTitle
    case custom(size: CGFloat, padding: EdgeInsets, color: Color)
    case legend
}

/// Configure the chart legend like chartTitle that can be updated after initial setting and configuration about if the legend of a datapoint should be dispayed
/// and how it is delimited from the chart value
public class ExtentedSwiftUIChartConfig: ObservableObject {
    @Published public var chartTitle: String
    @Published public var dataPointLegendDelimiter: String
    @Published public var displayDataPointLegend: Bool
    
    /// Initialize the extended chart legend conifugration
    /// - Parameters:
    ///   - title: chart title
    ///   - dataPointLegendDelimiter: text to be dieplayed between data point and the data point legend
    ///   - displayDataPointLegend: if false no data point legend is displayed in the chart title even if the chart data contains the string value
    public init(title: String, dataPointLegendDelimiter: String, displayDataPointLegend: Bool) {
        self.chartTitle = title
        self.dataPointLegendDelimiter = dataPointLegendDelimiter
        self.displayDataPointLegend = displayDataPointLegend
    }
    
    /// sets the chart legend to a new title
    /// - Parameter title: chart title to be used
    public func setTitle(title: String) {
        self.chartTitle = title
    }
    
    /// set a new text that should be displayed between data point value and data point legend in case of chart selection
    /// - Parameter displayDataPointLegend: text to be displayed between data point value and data point legend
    public func setDataPointLegendDisplayStatus(displayDataPointLegend: Bool) {
        self.displayDataPointLegend = displayDataPointLegend
    }
    
    /// define if the legend shoud be displayed if a data point is selected
    /// - Parameter dataPointLegendDelimiter: if false no legend for a selected data point is shown even if the data point has a legend information
    public func setDataPointLegendDelimiter(dataPointLegendDelimiter: String) {
        self.dataPointLegendDelimiter = dataPointLegendDelimiter
    }
}

/// A chart may contain any number of labels in pre-set positions based on their `ChartLabelType`
public struct ChartLabel: View {
    @EnvironmentObject var chartValue: ChartValue
    @EnvironmentObject var chartConfig: ExtentedSwiftUIChartConfig
    @State var textToDisplay:String = ""
    var format: String = "%.01f"

    private var title: String

	/// Label font size
	/// - Returns: the font size of the label
    private var labelSize: CGFloat {
        switch labelType {
        case .title:
            return 32.0
        case .legend:
            return 14.0
        case .subTitle:
            return 24.0
        case .largeTitle:
            return 38.0
        case .custom(let size, _, _):
            return size
        }
    }

	/// Padding around label
	/// - Returns: the edge padding to use based on position of the label
    private var labelPadding: EdgeInsets {
        switch labelType {
        case .title:
            return EdgeInsets(top: 16.0, leading: 8.0, bottom: 0.0, trailing: 8.0)
        case .legend:
            return EdgeInsets(top: 4.0, leading: 8.0, bottom: 0.0, trailing: 8.0)
        case .subTitle:
            return EdgeInsets(top: 8.0, leading: 8.0, bottom: 0.0, trailing: 8.0)
        case .largeTitle:
            return EdgeInsets(top: 24.0, leading: 8.0, bottom: 0.0, trailing: 8.0)
        case .custom(_, let padding, _):
            return padding
        }
    }

	/// Which type (color, size, position) for label
    private let labelType: ChartLabelType

	/// Foreground color for this label
	/// - Returns: Color of label based on its `ChartLabelType`
    private var labelColor: Color {
        switch labelType {
        case .title:
#if !os(macOS)
            return Color(UIColor.label)
#else
            return Color(NSColor.labelColor)
#endif
        case .legend:
#if !os(macOS)
            return Color(UIColor.secondaryLabel)
#else
            return Color(NSColor.secondaryLabelColor)
#endif
        case .subTitle:
#if !os(macOS)
            return Color(UIColor.label)
#else
            return Color(NSColor.labelColor)
#endif
        case .largeTitle:
#if !os(macOS)
            return Color(UIColor.label)
#else
            return Color(NSColor.labelColor)
#endif
        case .custom(_, _, let color):
            return color
        }
    }

	/// Initialize
	/// - Parameters:
	///   - title: Any `String`
	///   - type: Which `ChartLabelType` to use
    public init (_ title: String,
                 type: ChartLabelType = .title,
                 format: String = "%.01f") {
        self.title = title
        labelType = type
        self.format = format
    }

	/// The content and behavior of the `ChartLabel`.
	///
	/// Displays current value if chart is currently being touched along a data point, otherwise the specified text.
    public var body: some View {
        HStack {
            Text(textToDisplay)
                .font(.system(size: labelSize))
                .bold()
                .foregroundColor(self.labelColor)
                .padding(self.labelPadding)
                .onAppear {
                  //  self.textToDisplay = self.title
                   self.textToDisplay = self.chartConfig.chartTitle
                }
                .onReceive(self.chartValue.objectWillChange) { _ in
                    // if no data text is available only display data point value
                    if self.chartValue.currentText != "" {
                        // don't display data legend even if the data contains a text
                        if self.chartConfig.displayDataPointLegend == false {
                            self.textToDisplay = self.chartValue.interactionInProgress ? String(format: format, self.chartValue.currentValue): self.chartConfig.chartTitle
                        } else {
                            self.textToDisplay = self.chartValue.interactionInProgress ? String(format: format, self.chartValue.currentValue) + self.chartConfig.dataPointLegendDelimiter + String(self.chartValue.currentText): self.chartConfig.chartTitle
                        }
                    } else {
                        self.textToDisplay = self.chartValue.interactionInProgress ? String(format: format, self.chartValue.currentValue): self.chartConfig.chartTitle
                    }
                    
                }
                .onReceive(self.chartConfig.objectWillChange) { _ in
                    self.textToDisplay = self.chartValue.interactionInProgress ? String(format: format, self.chartValue.currentValue) + String(self.chartValue.currentText): self.chartConfig.chartTitle
                }
            
            if !self.chartValue.interactionInProgress {
                Spacer()
            }
        }
    }
}
