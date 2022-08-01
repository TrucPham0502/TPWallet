//
//  WalletView.swift
//  TPWallet
//
//  Created by Truc Pham on 29/07/2022.
//

import SwiftUI
struct CardModel : Identifiable {
    let id : String
    let image : String
}
struct WalletView: View {
    @State var cards : [CardModel] = [
        .init(id: UUID().uuidString, image: "Credit_Card_0"),
        .init(id: UUID().uuidString, image: "Credit_Card_1"),
        .init(id: UUID().uuidString, image: "Credit_Card_2"),
        .init(id: UUID().uuidString, image: "Credit_Card_0"),
        .init(id: UUID().uuidString, image: "Credit_Card_1"),
        .init(id: UUID().uuidString, image: "Credit_Card_2"),
        .init(id: UUID().uuidString, image: "Credit_Card_0"),
        .init(id: UUID().uuidString, image: "Credit_Card_1"),
        .init(id: UUID().uuidString, image: "Credit_Card_2"),
        
    ]
    @State var cardNumber: String = ""
    @State var cardHolderName : String = ""
    @State var expirationDate : String = ""
    @State var securityCode : String = ""
    @State var isAdding : Bool = false
    @State var currentIndexCard : Int = 0
    
    var body: some View {
        GeometryReader{ proxy in
            ZStack {
                Circle().fill(Color("00D7FF")).frame(width: 200, height: 200).offset(x: proxy.size.width - 250, y: proxy.size.height - 450).blur(radius: 100)
                VStack {
                    HStack {
                        Button {

                        } label: {
                            Image("Arrow_Left_Button")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        Spacer()
                        Text("Wallet").foregroundColor(.white)
                            .font(.system(size: 20)).bold()
                        Spacer()
                        Button {

                        } label: {
                            Image("More_Vertical")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }.frame(height: 44)


                    let tabData : [String] = ["Cards", "Account"]
                    TPTabView(data: tabData, onTap: { item in
                        print(item)
                    }).padding(.top, 20)
                        .padding(.bottom, 20)

                    cardView()
                    .padding(.bottom, 20)

                    PageControl(numberOfPages: cards.count, currentPage: $currentIndexCard)
                        .currentPageIndicatorTintColor(Color("0EA6C2"))
                        .padding(.bottom, 20)
                        .opacity(isAdding ? 0 : 1)
                        .frame(width: 100)


                    let icons = ["Send2","Wallet Icon","Send1", "Statistic icon"]
                    HStack(spacing: 20) {
                        ForEach(icons, id: \.self){icon in
                            Image(icon).resizable()
                                .frame(width: 50, height: 50)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1).fill(.white.opacity(0.12))
                                )
                        }
                    }.padding(.bottom, 30)
                        .opacity(isAdding ? 0 : 1)
                        .offset(x: isAdding ? 300 : 0)

                    addCardForm()
                    .padding()
                    .frame(maxWidth: CGFloat.infinity, alignment: .leading)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 20).fill(Color("7B78AA").opacity(0.5))
                            RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1).fill(Color.white.opacity(0.5))
                        }
                    )
                    .offset(y: isAdding ? -200 : 0)
                }
                .padding(.horizontal)
                .background(Color.clear)
            }.frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
                .background(Color("19173D").ignoresSafeArea())
        }
        
    }
    
    @ViewBuilder
    func cardView() -> some View {
        ZStack(alignment: .top) {
            ForEach(cards.enumerated().reversed(), id: \.element.id) {d in
                CardView(isCollapse: $isAdding, cards: $cards, index: d.offset) {index in
                    if currentIndexCard < cards.count - 1 { currentIndexCard += 1 }
                    else { currentIndexCard = 0}
                    print(cards[index].image)
                }
            }
        }
        .frame(height: 220 + 40, alignment: .bottom)
    }
    
    @ViewBuilder
    func addCardForm() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    withAnimation(.spring()){
                        isAdding = true
                    }
                } label: {
                    Image("plus_icon").resizable().frame(width: 24, height: 24)
                }
                Text("Add Card").foregroundColor(.white).font(.system(size: 20).bold())
            }
            Text("Add your debit/credit card").font(.system(size: 15)).foregroundColor(Color("7B78AA"))
                .padding(.leading, 30)
                .padding(.bottom, 30)
            
            
            VStack(spacing: 20) {
                TextField("", text: $cardNumber)
                    .placeholder(when: cardNumber.isEmpty, placeholder: {
                        Text("Card number").foregroundColor(Color("7B78AA"))
                    })
                    .padding(.horizontal, 10)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 15).fill(Color("19173D").opacity(0.5))
                    )
                TextField("", text: $cardHolderName)
                    .placeholder(when: cardHolderName.isEmpty, placeholder: {
                        Text("Card holder name").foregroundColor(Color("7B78AA"))
                    })
                    .padding(.horizontal, 10)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 15).fill(Color("19173D").opacity(0.5))
                    )
                
                HStack(spacing: 5) {
                    TextField("", text: $expirationDate)
                        .placeholder(when: expirationDate.isEmpty, placeholder: {
                            Text("Expiration Date").foregroundColor(Color("7B78AA"))
                        })
                        .padding(.horizontal, 10)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(Color("19173D").opacity(0.5))
                        )
                        .frame(maxWidth: CGFloat.infinity)
                    Spacer()
                    TextField("", text: $securityCode)
                        .placeholder(when: securityCode.isEmpty, placeholder: {
                            Text("Security Code").foregroundColor(Color("7B78AA"))
                        })
                        .padding(.horizontal, 10)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(Color("19173D").opacity(0.5))
                        )
                        .frame(maxWidth: CGFloat.infinity)
                }
                
                Button {
                    
                } label: {
                    Text("Next").foregroundColor(.white)
                        .font(.system(size: 15).bold())
                        .padding(.horizontal, 60)
                        .padding(.vertical, 15)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1).fill(.white.opacity(0.5))
                                RoundedRectangle(cornerRadius: 20).fill(LinearGradient(colors: [Color("0DA6C2"),Color("0E39C6")], startPoint: .topLeading, endPoint: .bottomTrailing))
                            }
                        )
                }
            }
            
        }
    }
    
}

struct CardView : View {
    @State var cardTranslation : CGFloat = 0
    @GestureState var isDragging : Bool = false
    @Binding var isCollapse : Bool
    @Binding var cards : [CardModel]
    let index : Int
    var endSwipe : (Int) -> () = {_ in }
    var body: some View {
        let width : CGFloat = 350
        let height : CGFloat = 220
        let topOffset : CGFloat = CGFloat(index <= 2 ? index : 2)*20
        let item : CardModel? = index > -1 && index < cards.count - 1 ? cards[index] : nil
        Image(item?.image ?? "")
            .resizable()
            .frame(width: width - topOffset, height: height)
            .rotationEffect(.init(degrees: Double(cardTranslation / (UIScreen.main.bounds.width - 20) * 8)))
            .offset(y: isCollapse ? -40 : -topOffset)
            .offset(x: cardTranslation)
            .contentShape(Rectangle())
            .gesture(DragGesture().updating($isDragging, body: { value, out, _ in
                out = true
            }).onChanged({ value in
                cardTranslation = isDragging && !isCollapse ? value.translation.width : .zero
            }).onEnded({ value in
                guard !isCollapse else { return }
                let width = UIScreen.main.bounds.width - 20
                let translation = value.translation.width
                let checkingStatus = (translation > 0 ? translation : -translation)
                withAnimation{
                    if checkingStatus > width / 2 {
                        cardTranslation = 0//(translation > 0 ? width : -width) * 2
                        endSwipe(index)
                        if let item = item {
                            cards.append(item)
                        }
                        cards.removeFirst()
                    }
                    else {
                        cardTranslation = 0
                    }
                    
                }
            }))
            .onTapGesture {
                withAnimation{
                    isCollapse = false
                }
            }
    }
}

struct PageControl : UIViewRepresentable {
    let pageControl = UIPageControl()
    let numberOfPages : Int
    @Binding var currentPage : Int
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.numberOfPages = numberOfPages
        uiView.currentPage = currentPage
    }
    func pageIndicatorTintColor(_ color : Color) -> Self {
        pageControl.pageIndicatorTintColor = UIColor(color)
        return self
    }
    
    func tintColor(_ color : Color) -> Self {
        pageControl.tintColor = UIColor(color)
        return self
    }
    func currentPageIndicatorTintColor(_ color : Color) -> Self {
        pageControl.currentPageIndicatorTintColor = UIColor(color)
        return self
    }
    
    func makeUIView(context: Context) -> UIPageControl {
        return pageControl
    }
}

extension TextField {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
    }
}
