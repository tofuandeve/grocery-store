require 'csv'

class Order
    STATUSES = [:pending, :paid, :processing, :shipped, :complete]
    
    attr_reader :id, :products, :customer, :fulfillment_status
    
    def initialize(id, products, new_customer, status = :pending)
        @id = id
        @products = products
        @customer = new_customer
        raise ArgumentError.new("No fulfillment status were given!") if !STATUSES.include? status
        @fulfillment_status = status
    end
    
    def total
        return (@products.values.sum * (1 + 0.075)).round(2)
    end
    
    def add_product(product_name, product_price)
        raise ArgumentError.new("Sorry you can't buy one product twice!") if @products.keys.include? product_name
        @products[product_name] = product_price
    end
    
    def remove_product(product_name)
        raise ArgumentError.new("Product name: #{product_name.capitalize} not found!") if !@products.keys.include? product_name
        @products.delete(product_name)
    end
    
    def self.all
        order_list = []
        CSV.read("data/orders.csv", headers: true).each do |line|
            products = Hash.new
            
            products_array = line["products"].split(';')
            products_array.each do |product|
                temp = product.split(':')
                products["#{temp[0]}"] = temp[1].to_f
            end
            
            customer = Customer.find(line["customer"].to_i)
            if customer
                order_list << Order.new(line["id"].to_i, products, customer, line["status"].to_sym)
            end
        end
        return order_list
    end
end