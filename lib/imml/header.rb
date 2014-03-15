# TODO
module IMML
  module Header

    class Param
      attr_accessor :name, :value

      def self.create(name,value)
        param=Param.new
        param.name=name
        param.value=value
        param
      end

      def parse(node)
        @name=node[:name]
        @value=node[:value]
      end

      def write(xml)
        xml.param(:name => self.name, :value => self.value)
      end
    end

    class Authentication
      attr_accessor :api_key

      def self.create(api_key)
        authentication=Authentication.new
        authentication.api_key=api_key
        authentication
      end

      def parse(node)
        @api_key=node[:api_key]
      end

      def write(xml)
        xml.authentication(:api_key => self.api_key)
      end
    end

    class Reseller
      attr_accessor :reseller_id, :reseller_dilicom_gencod

      def self.create(reseller_id,reseller_dilicom_gencod=nil)
        reseller=Reseller.new
        reseller.reseller_id=reseller_id
        reseller.reseller_dilicom_gencod=reseller_dilicom_gencod
        reseller
      end

      def parse(node)
        @reseller_id=node[:reseller_id]
        @reseller_dilicom_gencod=node[:reseller_dilicom_gencod]
      end

      def write(xml)
        xml.reseller(:reseller_id => self.reseller_id, :reseller_dilicom_gencod => self.reseller_dilicom_gencod)
      end

    end

    class Test
      attr_accessor :receive_url, :check_url, :sales_url

      def self.create(receive_url,check_url,sales_url)
        test=Test.new
        test.receive_url=receive_url
        test.check_url=check_url
        test.sales_url=sales_url
        test
      end

      def parse(node)
        node.children.each do |child|
          case child.name
            when "receive"
              @receive_url=child[:url]
            when "check"
              @check_url=child[:url]
            when "sales"
              @sales_url=child[:url]
          end
        end
      end

      def write(xml)
        xml.test {
          if self.receive_url
            xml.receive(:url => self.receive_url)
          end
          if self.check_url
            xml.check(:url => self.check_url)
          end
          if self.sales_url
            xml.sales(:url => self.sales_url)
          end
        }
      end

    end

    class Header
      attr_accessor :params, :authentication, :reseller, :test, :reason

      def self.create
        Header.new
      end

      def initialize
        @params=[]
      end

      def parse(node)
        node.children.each do |child|
          case child.name
            when "params"
              child.children.each do |param_node|
                if param_node.element?
                  param=Param.new
                  param.parse(param_node)
                  @params << param
                end
              end
            when "authentication"
              @authentication=Authentication.new
              @authentication.parse(child)
            when "reseller"
              @reseller=Reseller.new
              @reseller.parse(child)
            when "test"
              @test=Test.new
              @test.parse(child)
          end
        end
      end

      def write(xml)

        xml.header {
          if @params.length > 0
            xml.params {
              self.params.each do |param|
                param.write(xml)
              end
            }
          end
          if self.authentication
            self.authentication.write(xml)
          end
          if self.reseller
            self.reseller.write(xml)
          end
          if self.test
            self.test.write(xml)
          end
        }

      end
    end
  end
end