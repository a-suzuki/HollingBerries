#encoding: utf-8

require 'csv'
require 'date'

#この人たちがItemクラスのメソッドになればいいな
def to_R_dollar(cost_price)
  cost_price.to_f / 100
end

def get_margin(supplier_id, product_code)
  product_type = get_product_type(product_code)
  margin = {"リンゴ" => 0.4, "バナナ" => 0.35, "ベリー" => 0.55, "その他" => 0.5}[product_type]
  if premium_supplier? supplier_id
    margin = margin + 0.1
  end
  margin
end

def discount(supplier_id, price)
  penalty_price_down = get_penalty_price supplier_id
  discount_price = price - penalty_price_down
  if discount_price < 0
    return 0
  else
    return discount_price
  end
end

def get_selling_price(supplier_id, product_code, cost_price)
  margin = get_margin(supplier_id, product_code)
  selling_price = cost_price + (cost_price * margin)
  r_dollar = to_R_dollar(selling_price)
  if premium_supplier? supplier_id
    return r_dollar.ceil
  end

  discount(supplier_id, r_dollar)

end

def get_best_before_days(product_code)
  product_type = get_product_type(product_code)
  {"リンゴ" => 14, "バナナ" => 5, "ベリー" => 7, "その他" => 7}[product_type]
end

def penalty_supplier?(supplier_id)
  [32, 101].include? supplier_id
end

def premium_supplier?(supplier_id)
  [204, 219].include? supplier_id
end

def get_penalty_price(supplier_id)
  if penalty_supplier? supplier_id
    return 2
  else
    return 0
  end
end

def get_penalty_days(supplier_id)
  if penalty_supplier? supplier_id
    return 3
  else
    return 0
  end
end

def get_limit_date(supplier_id, product_code, derivery_date)
  best_before_days = get_best_before_days(product_code)
  penalty_days = get_penalty_days(supplier_id)
  derivery_date + best_before_days - penalty_days
end

def cut_description(str)
  str[0..30]
end

def get_product_type(product_code)
  case product_code
  when 1100..1199
    "リンゴ"
  when 1200..1299
    "バナナ"
  when 1300..1399
    "ベリー"
  else
    "その他"
  end
end

def main

  lines = CSV.read("produce.csv")
  lines.shift

  input_items = []

  lines.each do |line|
    item = {
      supplier_id: line[0].to_i,
      product_code: line[1].to_i,
      disription: line[2],
      derivery_date: Date::parse(line[3]),
      cost_price: line[4].to_i,
      unit_count: line[5].to_i
    }
    input_items << item
  end

  output_items = input_items.map do |input_item|
    {
      selling_price: get_selling_price(input_item[:supplier_id], input_item[:product_code], input_item[:cost_price]),
      limit_date: get_limit_date(input_item[:supplier_id], input_item[:product_code], input_item[:derivery_date]),
      description: cut_description(input_item[:disription]),
      unit_count: input_item[:unit_count]
    }
  end

  p output_items

  file = open("pricefile.txt", 'w')

  output_items.each do |item|
    price = item[:selling_price]
    limit_date = item[:limit_date].strftime("%Y/%m/%d")
    description = item[:description]
    p description
    unit_count = item[:unit_count]
    unit_count.times do
      file.puts sprintf("R%8.2f%s%s", price, limit_date, description)
    end
  end

  file.close
end

main

