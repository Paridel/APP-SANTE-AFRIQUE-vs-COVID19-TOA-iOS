//
//  MainView.swift
//  TOA
//
//  Created by Steven on 7/2/20.
//  Copyright © 2020 Coolectif TOA. All rights reserved.
//


import Charts
import Foundation
import SwiftUI
import UIKit
import KenBurns
import Alamofire


struct MainView: View {
    
    @EnvironmentObject var settings: UserSettings
    
    @State private var scrollViewContentOffset = CGFloat(0)
    @State private var buttonOnTapAnimationStatus = false
    @State var selection : Country = Country(id: 0, name: "Congo (Brazzaville)", iso2: "cg", iso3: "cg") //initialized country to Congo
    
    @State var mathdroApiCountryResult : CountryCases = CountryCases(confirmed: CasesSubItem(value: 0), recovered: CasesSubItem(value: 0), deaths: CasesSubItem(value: 0)) //The default value of cases in a country are 0 util the API load remote data
    
    let isNavigationBarHidden: Bool = true
    let animatedViewHeight : CGFloat = 280
    let chartView =  PieChartSwiftUI()
    
    var data  = DataLoader(jsonFileName: "countries_list")
    
    var body: some View {
        
        GeometryReader { geometry in //{ outsideProxy in
            
            
            NavigationView{
                
                //localized textes
                
                ZStack(alignment: .topLeading){
                    
                    //This image in the back of the AnimatedView serves as a placeholder because the animage has an estimated 2 seconds delay to load
                    Image("covid_worms_bg")
                        .resizable()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight:   self.animatedViewHeight , alignment: .top)
                    
                    
                    AnimatedView(imageName: "covid_worms_bg")
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: self.animatedViewHeight, alignment: .top)
                    
                    HStack {
                        ZStack{
                            
                            //This and the next element are key overlays to keeps the animated with in harmony with the safeArea informations (time, battery)
                            Color.black.opacity(0.5).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: self.animatedViewHeight, alignment: .top)
                            
                            ZStack{
                                LinearGradient(gradient: Gradient(colors:
                                    [
                                        Color("colorLinearGradient1").opacity(0.3),//Color.gray.opacity(0.3),
                                        Color("colorLinearGradient2").opacity(0.1),
                                        Color("colorLinearGradient3").opacity(0.15),
                                        Color("colorLinearGradient4").opacity(0.3)
                                    ]
                                ), startPoint: .top, endPoint: .bottom)
                                
                                RadialGradient(gradient: Gradient(colors: [Color.white.opacity(0.8), Color.black.opacity(0.1)]), center: .trailing, startRadius: 10, endRadius: 120)//.padding(.top, 70)
                                
                            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: self.animatedViewHeight, alignment: .top)
                            
                            //The ternary here helps to avoid the animation from handling scroll-top Drag Events
                        }.offset(x:  self.scrollViewContentOffset > 0 ? 0 : self.scrollViewContentOffset, y: 0)
                        
                        
                        
                        Spacer(minLength: 0)
                        
                        ZStack{
                            
                            //This and the next element are key overlays to keeps the animated with in harmony with the safeArea informations (time, battery
                            Color.black.opacity(0.5).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: self.animatedViewHeight, alignment: .top)
                            
                            ZStack{
                                LinearGradient(gradient: Gradient(colors:
                                    [
                                        Color("colorLinearGradient1").opacity(0.3),//Color.gray.opacity(0.3),
                                        Color("colorLinearGradient2").opacity(0.1),
                                        Color("colorLinearGradient3").opacity(0.15),
                                        Color("colorLinearGradient4").opacity(0.3)
                                    ]
                                ), startPoint: .top, endPoint: .bottom)
                                
                                RadialGradient(gradient: Gradient(colors: [Color.white.opacity(0.8), Color.black.opacity(0.1)]), center: .leading, startRadius: 10, endRadius: 120)//.padding(.top, 70)
                                
                            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: self.animatedViewHeight, alignment: .top)
                            
                            //The ternary here helps to avoid the animation from handling scroll-top Drag Events
                        }.offset(x:  self.scrollViewContentOffset > 0 ? 0 : -self.scrollViewContentOffset, y: 0)
                        
                    }
                    
                    
                    VStack {
                        TrackableScrollView(.vertical, contentOffset: self.$scrollViewContentOffset) {
                            //ScrollView(.vertical, showsIndicators: false){
                            
                            VStack(alignment: .center, spacing: 0){
                                ZStack{
                                    
                                    HStack {
                                        
                                        VStack(alignment: .leading, spacing: 6) {
                                            
                                            Image(self.selection.iso2.lowercased())
                                                .aspectRatio(contentMode: ContentMode.fit)
                                            
                                            VStack(alignment: .leading, spacing: 1){ Text("mainConfirmedCases"); Text("\(self.mathdroApiCountryResult.confirmed.value)").foregroundColor(Color.yellow) }
                                            
                                            VStack(alignment: .leading, spacing: 1){ Text("mainRecoveredCases"); Text("\(self.mathdroApiCountryResult.recovered.value)").foregroundColor(Color.yellow) }
                                            
                                            VStack(alignment: .leading, spacing: 1){ Text("mainDeceasedCases"); Text("\(self.mathdroApiCountryResult.deaths.value)").foregroundColor(Color.yellow) }
                                            
                                        }.foregroundColor(Color.white)
                                            .font(.subheadline)
                                            .offset(x: 0, y: self.scrollViewContentOffset < 0 ? self.scrollViewContentOffset: 0 )
                                            .animation(.easeOut)
                                        Spacer()
                                        
                                        Picker(selection: self.$selection, label: Text("")) {
                                            //ForEach( Array(self.data.countriesArray.enumerated()), id: \.1.id) {
                                            //ForEach( self.array, id : \.self ) { country in
                                            ForEach( self.data.countriesArray, id : \.self ) { country in
                                                //self.selectedCountry = country
                                                
                                                Text(" \(country.name)").font(.subheadline).foregroundColor(Color.white).tag(country)
                                                
                                            }
                                            
                                        }.frame(width: 120, height: 100)
                                            .opacity(self.scrollViewContentOffset < -50 ? 0.0 : 1.0)
                                            .animation(.easeInOut)
                                            .onReceive([self.selection].publisher.first()){ (country) in
                                                
                                                //debugPrint(value)
                                                self.loadCovidData()
                                        }
                                        
                                    }//.background(Color("colorBookBackground"))
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                                    
                                    
                                    
                                    HStack{
                                        //App logo
                                        Image("logo_round")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 100, height: 100)
                                            
                                            .shadow(color: Color.white, radius: 3, x: 0, y: 3)
                                        
                                        
                                    }.padding(EdgeInsets(top:  /* status bar heigh - safeArea top padding defined in the parent view*/   80  , leading: .zero, bottom: 2, trailing: .zero))
                                    
                                } .padding(EdgeInsets(top: geometry.safeAreaInsets.top + 10, leading: 10, bottom: 10, trailing: 10))
                                
                                
                                
                                HStack{
                                    Text("mainIntro")
                                        .multilineTextAlignment(.leading)
                                        .font( .system(size: self.settings.textSize ? 14 : 17))
                                        .padding(.all, 8)
                                    
                                }
                                .background(Color("colorBookBackground"))
                                .cornerRadius(6)
                                .padding(.horizontal, 15.9)
                                
                                
                                PreventionButtonView() //The first button (Prevention) - ZStack
                                
                                AnalysisButtonView() //The second button (Analysis) - ZStack
                                
                                
                                Text("mainAnalysisComment")
                                    .font( self.settings.textSize ? .subheadline : .system(size: 16))
                                    .multilineTextAlignment(.center)
                                    .padding(EdgeInsets(top: 4, leading: 13, bottom: 20, trailing: 13))
                                //no padding is needed bewteen the last button and this text. The purpose is make them look like one
                                
                                
                                HStack{
                                    Spacer()
                                    ZStack{
                                        
                                        self.chartView
                                        .frame(width: 335, height: 330)
                                        
                                        VStack{
                                            Image(self.selection.iso2.lowercased())
                                                .aspectRatio(contentMode: ContentMode.fit)
                                            Text(self.selection.name)
                                                .font(.system(size: 9))
                                        }.offset(x: -8, y: 0)
                                    }
                                    
                                    
                                    Spacer()
                                }
                            }//VStack
                            
                        }//Schrollview
                        
                        
                        HStack{
                            Spacer()
                            Text("credits")
                                .font(.footnote)
                            Spacer()
                            
                            Text("btnPrivacyPolicies")
                                .font(.footnote)
                                .foregroundColor(Color.blue)
                                .onTapGesture {
                                    let urlComponents = URLComponents (string: "https://africadevs.github.io/toa/policies.html") //Th website differs by language
                                    UIApplication.shared.open ((urlComponents?.url!)!)
                            }
                            Spacer()
                        }
                        .padding(.all, 10)
                        
                        
                    }//VStack
                }.navigationBarTitle("Nav").navigationBarHidden(self.isNavigationBarHidden).edgesIgnoringSafeArea( self.isNavigationBarHidden ? .top : .top)
                // .onAppear(perform: self.loadCovidData)
                
            }//NavigationView
            
            
        }
        
    }
    
    //load cases from covid19.mathdro.id using Alamofire
    func loadCovidData( )   {
        let countryName = self.selection.name.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        do {
            
            try
                AF.request("https://covid19.mathdro.id/api/countries/\(countryName)")
                    .responseDecodable(of: CountryCases.self) { response in
                        
                        self.mathdroApiCountryResult  = response.value ?? CountryCases(confirmed: CasesSubItem(value: 0), recovered: CasesSubItem(value: 0), deaths: CasesSubItem(value: 0))
                        
                        self.chartView.refresh(countryCases: self.mathdroApiCountryResult)
                        debugPrint("Response: \(response)")
            }
        } catch {
            
        }
        
        //AF.request("URL").response { response in }
    }
}



struct ToolbarItem: View {
    
    var body: some View {
        HStack() {
            Image(systemName: "textformat.size").font(.headline)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        
        MainView( )
    }
}
 

