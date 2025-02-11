require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/skip_dsl'

require_relative '../lib/customer'
require_relative '../lib/order'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

describe "Order Wave 1" do
  let(:customer) do
    address = {
      street: "123 Main",
      city: "Seattle",
      state: "WA",
      zip: "98101"
    }
    Customer.new(123, "a@a.co", address)
  end
  
  describe "#initialize" do
    it "Takes an ID, collection of products, customer, and fulfillment_status" do
      id = 1337
      fulfillment_status = :shipped
      order = Order.new(id, {}, customer, fulfillment_status)
      
      expect(order).must_respond_to :id
      expect(order.id).must_equal id
      
      expect(order).must_respond_to :products
      expect(order.products.length).must_equal 0
      
      expect(order).must_respond_to :customer
      expect(order.customer).must_equal customer
      
      expect(order).must_respond_to :fulfillment_status
      expect(order.fulfillment_status).must_equal fulfillment_status
    end
    
    it "Accepts all legal statuses" do
      valid_statuses = %i[pending paid processing shipped complete]
      
      valid_statuses.each do |fulfillment_status|
        order = Order.new(1, {}, customer, fulfillment_status)
        expect(order.fulfillment_status).must_equal fulfillment_status
      end
    end
    
    it "Uses pending if no fulfillment_status is supplied" do
      order = Order.new(1, {}, customer)
      expect(order.fulfillment_status).must_equal :pending
    end
    
    it "Raises an ArgumentError for bogus statuses" do
      bogus_statuses = [3, :bogus, 'pending', nil]
      bogus_statuses.each do |fulfillment_status|
        expect {
          Order.new(1, {}, customer, fulfillment_status)
        }.must_raise ArgumentError
      end
    end
  end
  
  describe "#total" do
    it "Returns the total from the collection of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Order.new(1337, products, customer)
      
      expected_total = 5.36
      
      expect(order.total).must_equal expected_total
    end
    
    it "Returns a total of zero if there are no products" do
      order = Order.new(1337, {}, customer)
      
      expect(order.total).must_equal 0
    end
  end
  
  describe "#add_product" do
    it "Increases the number of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      before_count = products.count
      order = Order.new(1337, products, customer)
      
      order.add_product("salad", 4.25)
      expected_count = before_count + 1
      expect(order.products.count).must_equal expected_count
    end
    
    it "Is added to the collection of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Order.new(1337, products, customer)
      
      order.add_product("sandwich", 4.25)
      expect(order.products.include?("sandwich")).must_equal true
    end
    
    it "Raises an ArgumentError if the product is already present" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      
      order = Order.new(1337, products, customer)
      before_total = order.total
      
      expect {
        order.add_product("banana", 4.25)
      }.must_raise ArgumentError
      
      # The list of products should not have been modified
      expect(order.total).must_equal before_total
    end
  end
  
  describe "#remove_product" do
    it "Raises ArgumentError if product name being passed in doesn't exist in product list" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      
      order = Order.new(1337, products, customer)
      before_total = order.total
      
      expect {
        order.remove_product("ice-cream")
      }.must_raise ArgumentError
      
      # The list of products should not have been modified
      expect(order.total).must_equal before_total
    end
    
    it "Removes product out of product list" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      
      order = Order.new(1337, products, customer)
      before_total = order.total
      
      product_name = "banana"
      order.remove_product(product_name)
      
      # The list of products should have been modified
      expect(order.total).wont_equal before_total
      expect(order.products.keys.include? product_name).must_equal false
    end
  end
end

# TODO: change 'xdescribe' to 'describe' to run these tests
describe "Order Wave 2" do
  describe "Order.all" do
    it "Returns an array of all orders" do
      order = Order.all
      
      expect (order).must_be_instance_of Array
      expect (order.sample).must_be_instance_of Order
      expect (order.length).must_equal 100
    end
    
    it "Returns accurate information about the first order" do
      id = 1
      products = {
        "Lobster" => 17.18,
        "Annatto seed" => 58.38,
        "Camomile" => 83.21
      }
      customer_id = 25
      fulfillment_status = :complete
      
      order = Order.all.first
      
      # Check that all data was loaded as expected
      expect(order.id).must_equal id
      expect(order.products).must_equal products
      expect(order.customer).must_be_kind_of Customer
      expect(order.customer.id).must_equal customer_id
      expect(order.fulfillment_status).must_equal fulfillment_status
    end
    
    it "Returns accurate information about the last order" do
      id = 100
      products = {
        "Amaranth" => 83.81,
        "Smoked Trout" => 70.6,
        "Cheddar" => 5.63
      }
      customer_id = 20
      fulfillment_status = :pending
      
      order = Order.all.last
      
      # Check that all data was loaded as expected
      expect(order.id).must_equal id
      expect(order.products).must_equal products
      expect(order.customer).must_be_kind_of Customer
      expect(order.customer.id).must_equal customer_id
      expect(order.fulfillment_status).must_equal fulfillment_status
    end
  end
  
  describe "Order.find" do
    it "Can find the first order from the CSV" do
      id = 1
      products = {
        "Lobster" => 17.18,
        "Annatto seed" => 58.38,
        "Camomile" => 83.21
      }
      customer_id = 25
      fulfillment_status = :complete
      
      order = Order.find(1)
      
      # Check that all data was loaded as expected
      expect(order.id).must_equal id
      expect(order.products).must_equal products
      expect(order.customer).must_be_kind_of Customer
      expect(order.customer.id).must_equal customer_id
      expect(order.fulfillment_status).must_equal fulfillment_status
      
    end
    
    it "Can find the last order from the CSV" do
      id = 100
      products = {
        "Amaranth" => 83.81,
        "Smoked Trout" => 70.6,
        "Cheddar" => 5.63
      }
      customer_id = 20
      fulfillment_status = :pending
      
      order = Order.find(100)
      
      # Check that all data was loaded as expected
      expect(order.id).must_equal id
      expect(order.products).must_equal products
      expect(order.customer).must_be_kind_of Customer
      expect(order.customer.id).must_equal customer_id
      expect(order.fulfillment_status).must_equal fulfillment_status
    end
    
    it "Returns nil for an order that doesn't exist" do
      id = 150
      assert_nil(Order.find(id))
    end
  end
  
  describe "Order.find_by_customer" do
    
    it "Returns and array of orders" do
      customer_id = 20
      customer_orders = 7
      orders = Order.find_by_customer(customer_id)
      
      expect (orders).must_be_instance_of Array
      expect (orders.length).must_equal customer_orders
      expect (orders.sample).must_be_instance_of Order
    end
    
    it "Returns and array of orders of one customer" do
      customer_id = 20
      customer_orders = 7
      orders = Order.find_by_customer(customer_id)
      
      expect (orders).must_be_instance_of Array
      expect (orders.length).must_equal customer_orders
      expect (orders.sample).must_be_instance_of Order
      expect (orders.sample.customer.id).must_equal customer_id 
    end
    
    it "Returns empty array for a customer that doesn't exist" do
      customer_id = 80
      expect (Order.find_by_customer(customer_id)).must_be_empty
    end
  end
end
