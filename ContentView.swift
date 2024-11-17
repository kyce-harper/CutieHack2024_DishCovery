import SwiftUI

struct ContentView: View {
    @State private var meals: [Meal] = []
    @State private var selectedMeal: Meal? = nil
    @State private var userInput: String = ""
    @State private var isLoading = false
    @State private var isDetailDesc = false
    @State private var detailPlaceHolder: Meal? = nil
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack {
                Spacer().frame(height:25)
                Image("dishCoveryLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 325, height: 80)
                
                Spacer().frame(height:10)
                TextField("Enter food choice", text: $userInput)
                    .padding()
                    .background(Color.c)
                    .foregroundColor(.black)
                    .cornerRadius(30)
                    .padding(.top, 20)
                Spacer().frame(height:25)
                // Button to fetch a random meal
                HStack{
                    Spacer().frame(width:10)
                    Button("Search   ") {
                        Task {
                            await fetchSearchMeal(x: userInput)
                        }
                    }.padding().background(Color.c).cornerRadius(10).font(.title2)
                    
                    

                    Spacer().frame(width:40)
                    // Button to enter user search
                    Button("Suprise Me!") {
                        Task {
                            meals = []
                            await fetchMeal()
                        }
                    }.padding().background(Color.c).cornerRadius(10).font(/*@START_MENU_TOKEN@*/.title3/*@END_MENU_TOKEN@*/)
                    Spacer().frame(width:10)
                }
                
                
                Spacer()
                
                if !meals.isEmpty {
                    ScrollView {
                        LazyVStack {
                            ForEach(meals, id: \.idMeal) { meal in
                                VStack {
                                    Text(meal.strMeal ?? "Unknown Meal")
                                        .font(.headline)
                                        .padding()
                                    
                                    AsyncImage(url: URL(string: meal.strMealThumb ?? "")) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .frame(width: 200, height: 200)
                                            .cornerRadius(30)
                                            .shadow(radius: 10)
                                    } placeholder: {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                    }
                                    
                                    Button("See More") {
                                        // Set the meal for detailed view
                                        detailPlaceHolder = meal
                                        isDetailDesc = true
                                    }
                                  
                                }
                                .padding(.top)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }
                        }
                    }
                } else if let meal = selectedMeal {
                    ScrollView {
                        VStack(alignment: .center, spacing: 20) {
                            Text(meal.strMeal ?? "Unknown Meal")
                                .font(.title)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            AsyncImage(url: URL(string: meal.strMealThumb ?? "")) { image in
                                image.resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(30)
                                    .shadow(radius: 40)
                            } placeholder: {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                            
                            HStack {
                                Spacer()
                                Text("Category: \(meal.strCategory ?? "N/A")")
                                    .padding()
                                
                                Text("Area: \(meal.strArea ?? "Unknown Area")")
                                    .padding()
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Ingredients:")
                                    .font(.headline)
                                    .padding(.top)
                                Text(meal.allIngredientsWithMeasurements.isEmpty ? "No ingredients available" : meal.allIngredientsWithMeasurements)
                                
                                Text("Instructions:")
                                    .font(.headline)
                                    .padding(.top)
                                Text(meal.strInstructions ?? "No instructions available")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $isDetailDesc) {
            if let meal = detailPlaceHolder {
                ScrollView {
                    VStack(alignment: .center, spacing: 20) {
                        Spacer().frame(height:20)
                        Text(meal.strMeal ?? "Unknown Meal")
                            .font(.title)
                        
                        if let url = URL(string: meal.strMealThumb ?? ""), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .cornerRadius(30)
                                .shadow(radius: 10)
                        } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack{
                                Spacer().frame(width:30)
                                Text("Category: \(meal.strCategory ?? "N/A")")
                                Spacer()
                                Text("Area: \(meal.strArea ?? "Unknown Area")")
                                Spacer().frame(width:30)
                            }
                            
                            
                            Text("Ingredients:")
                                .font(.headline)
                            Text(meal.allIngredientsWithMeasurements.isEmpty ? "No ingredients available" : meal.allIngredientsWithMeasurements)
                            
                            Text("Instructions:")
                                .font(.headline)
                            Text(meal.strInstructions ?? "No instructions available")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    func fetchMeal() async {
        isLoading = true
        do {
            let meals = try await fetchRandMeals()
            selectedMeal = meals.first
        } catch {
            print("Failed\(error)")
        }
        isLoading = false
    }
    
    func fetchSearchMeal(x: String) async {
        isLoading = true
        do {
            let meals = try await fetchSearchMeals(searchString: x)
            self.meals = meals
            selectedMeal = nil
        } catch {
            print("Failed\(error)")
        }
        isLoading = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
