# seeds.rb
require 'faker'

# Очищаем существующие данные
Comment.destroy_all
Blog.destroy_all
User.destroy_all

puts "Creating users..."
# Создаем админа
admin = User.create!(
  first_name: "Admin",
  last_name: "User",
  email: "admin@example.com",
  username: "admin",
  password: "password123",
  password_confirmation: "password123",
  admin: true,
  confirmed_at: Time.current
)

# Создаем обычных пользователей
10.times do |n|
  user = User.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: "user#{n+1}@example.com",
    username: Faker::Internet.unique.username(specifier: 5..10),
    password: "password123",
    password_confirmation: "password123",
    confirmed_at: Time.current
  )
  puts "Created user: #{user.username}"
end

puts "Creating blogs..."
users = User.where(admin: false)
20.times do
  blog = Blog.create!(
    title: Faker::Lorem.sentence(word_count: rand(3..8)), # Исправлено здесь
    description: Faker::Lorem.paragraph(sentence_count: 2),
    content: Faker::Lorem.paragraphs(number: rand(5..10)).join("\n\n"), # И здесь
    user: users.sample
  )
  puts "Created blog: #{blog.title}"
end

puts "Creating comments..."
blogs = Blog.all
users = User.all

# Создаем корневые комментарии
50.times do
  blog = blogs.sample
  comment = Comment.create!(
    text: Faker::Lorem.paragraph(sentence_count: rand(1..3)), # И здесь
    blog: blog,
    user: users.sample
  )
  puts "Created root comment for blog #{blog.id}"
end

# Создаем вложенные комментарии (ответы на комментарии)
root_comments = Comment.where(parent_comment_id: nil)
200.times do
  parent = root_comments.sample
  comment = Comment.create!(
    text: Faker::Lorem.paragraph(sentence_count: rand(1..3)), # И здесь
    blog: parent.blog,
    user: users.sample,
    parent_comment: parent
  )
  puts "Created nested comment for parent #{parent.id}"
  
  # С некоторой вероятностью создаем еще один уровень вложенности
  if rand < 0.3
    Comment.create!(
      text: Faker::Lorem.paragraph(sentence_count: rand(1..3)), # И здесь
      blog: parent.blog,
      user: users.sample,
      parent_comment: comment
    )
    puts "Created deeply nested comment"
  end
end

puts "Seeding completed successfully!"
puts "#{User.count} users created"
puts "#{Blog.count} blogs created"
puts "#{Comment.count} comments created"
puts "Admin credentials: email: admin@example.com, password: password123"