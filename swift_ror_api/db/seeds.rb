# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

5.times do |i|
    Todo.create(title: "Todo ##{i+1}", created_by: "User##{i+1}")
end

5.times do |i|
    Item.create(name: "Item ##{i+1}", done: false, todo_id: i)
end