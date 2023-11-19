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
    
    var dataServices = DataServices()
    
    //위젯 예제
    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> Void) {
        let entry = DayEntry(date: Date(), img: "happy")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
        var entries: [DayEntry] = []
        
        let currentDate = Date()
        for dayOffSet in 0...1 {
            var entryDate = Date()
            
            if dayOffSet == 1 {
                entryDate = Calendar.current.date(byAdding: .day, value: 0 ,to: currentDate)!
                entryDate = entryDate.setToMidnight()!
                dataServices.checkIfNewDay(entryDate)
            }
          
            let (img, _) = dataServices.getData()
            print("printing : \(img)")
            
            let entry = DayEntry(date: entryDate,
                                 img: img)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func placeholder(in context: Context) -> DayEntry {
        return DayEntry(date: Date(), img: "happy")
    }
}

struct DayEntry: TimelineEntry {
    let date: Date
    let img: String?
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
                
                Image(entry.img ?? "")
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
