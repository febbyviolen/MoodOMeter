//
//  DayWidget.swift
//  DayWidget
//
//  Created by Ebbyy on 11/11/23.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> Void) {
        let entry = DayEntry(date: Date(), img: "happy")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
        var entries: [DayEntry] = []
        
        let userDefaults = UserDefaults(suiteName: "group.febby.moody.widgetcache")
        var img = userDefaults?.value(forKey: "img") as? String ?? ""
        var date = userDefaults?.value(forKey: "date") as? Date ?? Date()
        
        let currentDate = Date()
        for dayOffSet in 0...1 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffSet ,to: currentDate)!
            let startOfDate = Calendar.current.startOfDay(for: entryDate)
            
            if startOfDate > date {
                userDefaults?.set("", forKey: "img")
                img = userDefaults?.value(forKey: "img") as? String ?? ""
                userDefaults?.set(startOfDate, forKey: "date")
            }
            
            userDefaults?.set(startOfDate, forKey: "date")
            let entry = DayEntry(date: startOfDate,
                                 img: img)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: Date(), img: "")
    }
}

struct DayEntry: TimelineEntry {
    let date: Date
    let img: String
}

//MARK: UI
struct DayWidgetEntryView : View {
    var entry: DayEntry

    var body: some View {
        
        ZStack{
            ContainerRelativeShape()
                .fill(.white)
            
            VStack{
                Text(String(format: NSLocalizedString("today.title", comment: "")))
                    .font(.body)
                    .foregroundColor(.black)
                    .bold()
                
                Image(entry.img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 30, idealWidth: 60, minHeight: 30, idealHeight: 60)
            }
            .padding()
        }
    }
}

struct DayWidget: Widget {
    let kind: String = "DayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(), content: { entry in
            DayWidgetEntryView(entry: entry)
        })
        .configurationDisplayName(String(format: NSLocalizedString("오늘", comment: "")))
        .description(String(format: NSLocalizedString("widget.today.message", comment: "")))
        .supportedFamilies([.systemSmall])
    }
}

struct DayWidget_Previews: PreviewProvider {
    static var previews: some View {
        DayWidgetEntryView(entry: DayEntry(date: Date(), img: ""))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
