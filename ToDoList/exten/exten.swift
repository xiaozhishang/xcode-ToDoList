//
//  exter.swift
//  exter
//
//  Created by 陆骁剑 on 2022/9/17.
//  Copyright © 2022 Moon. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}
//获取当天开始的日期，给Date增加一个拓展方法
 extension Date {
    func getCurrentDayStart(_ isDayOf24Hours: Bool)-> Date {
        let calendar:Calendar = Calendar.current;
        let year = calendar.component(.year, from: self);
        let month = calendar.component(.month, from: self);
        let day = calendar.component(.day, from: self);
    
        let components = DateComponents(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
        return Calendar.current.date(from: components)!
    }
}
// 实现一天内的计时器
//Text(Date().getCurrentDayStart(true), style: .timer)


struct exterEntryView : View {
    // 这句代码能从上下文环境中取到小组件的型号
        @Environment(\.widgetFamily) var family
        
        // 组件数据
        var entry: Provider.Entry
    
        @State  var currentSeconds: Int = 0
         var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        // 这个 body 中就是自己需要实现的组件布局
        var body: some View {
            switch family {
            case .systemSmall:  // 小号
                Text(entry.date, style: .time)
            case .systemMedium: // 中号
                 
                Text(Date().getCurrentDayStart(true), style: .timer)
                            .font(.system(size: 70))
                            .bold()
                            .shadow(radius: 10, x: 10, y: 10)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(hex: 0xB03060))
                            .italic()
                            .underline(true,color: Color(hex: 0xDB7093))
            case .systemLarge:  // 大号
                Text(entry.date, style: .time)
            case .systemExtraLarge:
                Text(entry.date, style: .time)
            case .accessoryCircular:
                Text(entry.date, style: .time)
            case .accessoryRectangular:
                Text(entry.date, style: .time)
            case .accessoryInline:
                Text(entry.date, style: .time)
            @unknown default:
                Text(entry.date, style: .time)
            }
        }
}

extension Color {
    init(hex: UInt32) {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8) / 255.0
        let blue = Double(hex & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
@main
struct exter: Widget {
    let kind: String = "exter"
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            exterEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct exter_Previews: PreviewProvider {
    static var previews: some View {
        exterEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
