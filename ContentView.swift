import SwiftUI

struct StudentProfile: Identifiable, Codable {
    let id: String
    var fullName: String
    var group: String
    var specialty: String
    var email: String
    var studentID: String
    var photoURL: String?
    
    static var placeholder: StudentProfile {
        StudentProfile(
            id: UUID().uuidString,
            fullName: "Кравцов Герман Данилович",
            group: "ІТШІ-23-1",
            specialty: "122 Компʼютерні науки",
            email: "herman.kravtsov@nure.ua",
            studentID: "ХА14310185",
            photoURL: "placeholder"
        )
    }
}

struct Task: Identifiable, Codable {
    let id: String
    var name: String
    var deadline: Date
    var description: String
    var isCompleted: Bool
    var ownerUID: String
    
    var isOverdue: Bool {
        !isCompleted && deadline < Date()
    }
    
    var deadlineString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: deadline)
    }
    
    init(id: String = UUID().uuidString, name: String, deadline: Date, description: String, isCompleted: Bool = false, ownerUID: String = "local") {
        self.id = id
        self.name = name
        self.deadline = deadline
        self.description = description
        self.isCompleted = isCompleted
        self.ownerUID = ownerUID
    }
}

class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []
    
    init() {
        loadLocalTasks()
    }
    
    private func loadLocalTasks() {
        let calendar = Calendar.current
        tasks = [
            Task(name: "Лабораторна робота №1",
                 deadline: calendar.date(byAdding: .day, value: 8, to: Date())!,
                 description: "Програмування на Python"),
            Task(name: "Практична робота №3",
                 deadline: calendar.date(byAdding: .day, value: 21, to: Date())!,
                 description: "Мобільний Internet, сервіси та технології"),
            Task(name: "Практична робота №2",
                 deadline: calendar.date(byAdding: .day, value: 15, to: Date())!,
                 description: "Інтелектуальний аналіз даних"),
            Task(name: "Тести",
                 deadline: calendar.date(byAdding: .day, value: 29, to: Date())!,
                 description: "Фізична підготовка"),
            Task(name: "Прострочене завдання",
                 deadline: calendar.date(byAdding: .day, value: -2, to: Date())!,
                 description: "Тест")
        ]
    }
    
    var sortedTasks: [Task] {
        tasks.sorted { $0.deadline < $1.deadline }
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
}

class AppState: ObservableObject {
    @Published var taskManager = TaskManager()
    @Published var studentProfile: StudentProfile = .placeholder
}

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color.blue.opacity(0.1), Color.indigo.opacity(0.2)],
                             startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Міні-портал студента")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.indigo)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        
                        VStack(spacing: 16) {
                            NavigationLink(destination: TasksView()) {
                                MenuButton(icon: "list.clipboard.fill",
                                         title: "Завдання та дедлайни",
                                         subtitle: "Відстежуйте свої завдання",
                                         color: .indigo)
                            }
                            
                            NavigationLink(destination: ProfileView()) {
                                MenuButton(icon: "person.fill",
                                         title: "Студентська картка",
                                         subtitle: "Ваша особиста інформація",
                                         color: .green)
                            }
                            
                            NavigationLink(destination: HealthView()) {
                                MenuButton(icon: "heart.fill",
                                         title: "Здоров'я та фокус",
                                         subtitle: "Поради та трекер здорових звичок",
                                         color: .pink)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct TasksView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddTask = false
    @State private var editingTask: Task?
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.indigo.opacity(0.1), Color.purple.opacity(0.2)],
                         startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Завдання та дедлайни")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.indigo)
                                Text("Ваші поточні завдання")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        
                        HStack(spacing: 16) {
                            StatCard(icon: "checkmark.circle.fill",
                                   value: "\(appState.taskManager.tasks.filter { $0.isCompleted }.count)",
                                   label: "Виконано",
                                   color: .green)
                            
                            StatCard(icon: "clock.fill",
                                   value: "\(appState.taskManager.tasks.filter { !$0.isCompleted && !$0.isOverdue }.count)",
                                   label: "Активні",
                                   color: .blue)
                            
                            StatCard(icon: "exclamationmark.triangle.fill",
                                   value: "\(appState.taskManager.tasks.filter { $0.isOverdue }.count)",
                                   label: "Прострочені",
                                   color: .red)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    ForEach(appState.taskManager.sortedTasks) { task in
                        TaskCard(task: task)
                            .onTapGesture {
                                editingTask = task
                            }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.indigo)
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            TaskEditView(task: nil)
        }
        .sheet(item: $editingTask) { task in
            TaskEditView(task: task)
        }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct TaskCard: View {
    @EnvironmentObject var appState: AppState
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Button(action: {
                    appState.taskManager.toggleTaskCompletion(task)
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(task.isCompleted ? .green : .gray)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .strikethrough(task.isCompleted)
                    
                    Text(task.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(task.deadlineString)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(task.isOverdue ? .white : .red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(task.isOverdue ? Color.red : Color.red.opacity(0.15))
                        .cornerRadius(20)
                    
                    if task.isOverdue && !task.isCompleted {
                        Text("Прострочено")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(task.isOverdue ? 0.1 : 0.05), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(task.isOverdue && !task.isCompleted ? Color.red.opacity(0.3) : Color.clear, lineWidth: 2)
        )
    }
}

struct TaskEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    let task: Task?
    
    @State private var name: String
    @State private var description: String
    @State private var deadline: Date
    
    init(task: Task?) {
        self.task = task
        _name = State(initialValue: task?.name ?? "")
        _description = State(initialValue: task?.description ?? "")
        _deadline = State(initialValue: task?.deadline ?? Date())
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Основна інформація") {
                    TextField("Назва завдання", text: $name)
                    TextField("Опис", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Дедлайн") {
                    DatePicker("Дата", selection: $deadline, displayedComponents: .date)
                }
                
                if task != nil {
                    Section {
                        Button("Видалити завдання", role: .destructive) {
                            if let task = task {
                                appState.taskManager.deleteTask(task)
                            }
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(task == nil ? "Нове завдання" : "Редагування")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти") {
                        saveTask()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveTask() {
        if let existingTask = task {
            var updated = existingTask
            updated.name = name
            updated.description = description
            updated.deadline = deadline
            appState.taskManager.updateTask(updated)
        } else {
            let newTask = Task(name: name, deadline: deadline, description: description)
            appState.taskManager.addTask(newTask)
        }
        dismiss()
    }
}

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.green.opacity(0.1), Color.teal.opacity(0.2)],
                         startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.green, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 140, height: 140)
                            
                            if let photoURL = appState.studentProfile.photoURL {
                                Image(photoURL)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 130, height: 130)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .foregroundColor(.white)
                            }
                        }
                        .shadow(color: .green.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        VStack(spacing: 8) {
                            Text(appState.studentProfile.fullName)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text(appState.studentProfile.specialty)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 0) {
                        ProfileRow(icon: "number", label: "Група", value: appState.studentProfile.group)
                        Divider().padding(.leading, 60)
                        ProfileRow(icon: "graduationcap.fill", label: "Спеціальність", value: appState.studentProfile.specialty)
                        Divider().padding(.leading, 60)
                        ProfileRow(icon: "envelope.fill", label: "Email", value: appState.studentProfile.email)
                        Divider().padding(.leading, 60)
                        ProfileRow(icon: "creditcard.fill", label: "Студентський квиток", value: appState.studentProfile.studentID)
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.green)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct HealthView: View {
    @State private var waterDone = false
    @State private var breakDone = false
    @State private var eyesDone = false
    @State private var stretchDone = false
    
    let tips = [
        "Правило 20-20-20: кожні 20 хвилин дивіться на об'єкт на відстані 20 метрів протягом 20 секунд",
        "Робіть перерву кожні 60 хвилин роботи за комп'ютером",
        "Підтримуйте правильну поставу: спина пряма, монітор на рівні очей",
        "Пийте достатньо води - мінімум 8 склянок на день",
        "Виконуйте вправи для шиї та плечей кожні 2 години"
    ]
    
    let exercises = [
        "Обертання головою (10 разів у кожен бік)",
        "Піднімання плечей (15 повторень)",
        "Нахили тулуба вліво-вправо (10 разів)",
        "Присідання (15 повторень)",
        "Розтяжка зап'ястя (по 30 секунд кожне)"
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.pink.opacity(0.1), Color.red.opacity(0.15)],
                         startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Здоров'я та фокус")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.pink)
                        Text("Підтримуйте здоров'я під час роботи за комп'ютером")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 5)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Корисні поради")
                            .font(.system(size: 20, weight: .bold))
                        
                        ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1).")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.pink)
                                Text(tip)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 3)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Вправи для розминки")
                            .font(.system(size: 20, weight: .bold))
                        
                        ForEach(exercises, id: \.self) { exercise in
                            HStack(alignment: .top, spacing: 12) {
                                Text("-")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.blue)
                                Text(exercise)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 3)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Трекер звичок (сьогодні)")
                            .font(.system(size: 20, weight: .bold))
                        
                        Toggle("Випив достатньо води", isOn: $waterDone)
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        
                        Toggle("Зробив перерву", isOn: $breakDone)
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        
                        Toggle("Вправи для очей", isOn: $eyesDone)
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        
                        Toggle("Розминка", isOn: $stretchDone)
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 3)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
