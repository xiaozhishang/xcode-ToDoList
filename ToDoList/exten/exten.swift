import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        return WeatherPoser.dafaultEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = WeatherPoser.dafaultEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        //设定1小时更新一次数据
        let updateDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        
        let entry = WeatherPoser.dafaultEntry()
        let timeline = Timeline(entries: [entry], policy: .after(updateDate))
        completion(timeline)
        
    
         /*// 真实网络请求
         WeatherPoser.requestNow { result in
         if case .success(let now) = result {
         let entry = Entry(date: currentDate, dataList: poster, cityName: String(name), today: now)
         let timeline = Timeline(entries: [entry], policy: .after(updateDate))
         completion(timeline)
         }
         }*/
         
        
    }
    
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let dataList: [WeatherModel]
    let cityName: String
    let today: Now
}

struct WeatherWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family:WidgetFamily
    
    var body: some View {
        switch family {
        case .systemSmall:
            VStack {
                Text("body")
            }
        case .systemMedium:
            MediumWeatherView(entry: entry)
        case .systemLarge:
            VStack {
                Text("body")
            }
        default:
            MediumWeatherView(entry: entry)
        }
    }
}

@main
struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("天气")
        .description("显示最近天气预报")
    }
}

struct WeatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        let entry = WeatherPoser.dafaultEntry()
        WeatherWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct MediumWeatherView: View {
    var entry: Provider.Entry
    var body: some View {
        VStack {
            HStack(alignment: .center){
                Image("blue_loc").frame(width: 12, height: 12, alignment: .center).aspectRatio(contentMode: .fit)
                Text(self.entry.cityName)
                Spacer()
                Text(self.entry.date, style: .date)
            }
            HStack(alignment: .center){
                if let text = self.entry.today.text {
                    Image(text).frame(width: 44, height: 44, alignment: .center).aspectRatio(contentMode: .fit)
                    let temperature = self.entry.today.temperature
                    Text((temperature + "°"))
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                }
                ForEach(entry.dataList) {item in
                    if item.id == 0 {
                        VStack {
                            Text(item.weather)
                            Text(item.temp)
                        }
                    }
                }
                Spacer()
            }
            Spacer()
            HStack(alignment: .center){
                ForEach(entry.dataList) {item in
                    if item.id > 0 {
                        WeatherDayView(item:item)
                    }
                }
            }
        }.padding(11.0)
    }
}

struct WeatherDayView: View {
    var item: WeatherModel
    var body: some View {
        HStack(alignment: .center, spacing: 12){
            Image(self.item.weather).frame(width: 30, height: 30, alignment: .center).aspectRatio(contentMode: .fit)
            VStack(alignment: .leading) {
                Text(self.item.title)
                    .font(.body)
                    .foregroundColor(Color(hue: 0.275, saturation: 0.74, brightness: 0.621))
                Text(self.item.temp)
                    .font(.body)
            }
        }
    }
}


struct Now: Identifiable {
    var temperature: String = ""
    var text: String = ""
    var id: Int = 0
}
struct WeatherModel: Identifiable {
    var weather: String = ""
    var title: String = ""
    var temp: String = ""
    var id: Int = 0
}

struct WeatherPoser {
    static func dafaultEntry() -> SimpleEntry {
        let dataList = [
            WeatherModel(weather: "晴", title: "今天", temp: "20/36°", id: 0),
            WeatherModel(weather: "晴", title: "明天", temp: "20/36°", id: 1),
            WeatherModel(weather: "晴", title: "后天", temp: "20/36°", id: 2),
            WeatherModel(weather: "晴", title: "周四", temp: "20/36°", id: 3)
        ]
        let now = Now(temperature: "30", text: "多云", id: 0)
        return SimpleEntry(date: Date(), dataList: dataList, cityName: "北京市", today: now)
    }
    
}
