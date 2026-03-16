# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

StockSector.find_or_create_by!(code: "defence") do |sector|
  sector.name = "Defence"
end

StockSector.find_or_create_by!(code: "automobile") do |sector|
  sector.name = "Automobile"
end

StockSector.find_or_create_by!(code: "it") do |sector|
  sector.name = "Information Technology"
end

StockCategory.find_or_create_by!(code: "large_cap") do |category|
  category.name = "Large Cap"
end

StockCategory.find_or_create_by!(code: "mid_cap") do |category|
  category.name = "Mid Cap"
end

StockCategory.find_or_create_by!(code: "small_cap") do |category|
  category.name = "Small Cap"
end
