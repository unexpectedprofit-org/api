require 'spec_helper'

describe Grape::Entity do
  let(:fresh_class) { Class.new(Grape::Entity) }

  context 'class methods' do
    subject { fresh_class }

    describe '.expose' do
      context 'multiple attributes' do
        it 'is able to add multiple exposed attributes with a single call' do
          subject.expose :name, :email, :location
          subject.exposures.size.should == 3
        end

        it 'sets the same options for all exposures passed' do
          subject.expose :name, :email, :location, :foo => :bar
          subject.exposures.values.each{|v| v.should == {:foo => :bar}}
        end
      end

      context 'option validation' do
        it 'makes sure that :as only works on single attribute calls' do
          expect{ subject.expose :name, :email, :as => :foo }.to raise_error(ArgumentError)
          expect{ subject.expose :name, :as => :foo }.not_to raise_error
        end

        it 'makes sure that :format_with as a proc can not be used with a block' do
          expect { subject.expose :name, :format_with => Proc.new {} do |_| end }.to raise_error(ArgumentError)
        end
      end

      context 'with a block' do
        it 'errors out if called with multiple attributes' do
          expect{ subject.expose(:name, :email) do
            true
          end }.to raise_error(ArgumentError)
        end

        it 'sets the :proc option in the exposure options' do
          block = lambda{|_| true }
          subject.expose :name, &block
          subject.exposures[:name][:proc].should == block
        end
      end

      context 'inherited exposures' do
        it 'returns exposures from an ancestor' do
          subject.expose :name, :email
          child_class = Class.new(subject)

          child_class.exposures.should eq(subject.exposures)
        end

        it 'returns exposures from multiple ancestor' do
          subject.expose :name, :email
          parent_class = Class.new(subject)
          child_class  = Class.new(parent_class)

          child_class.exposures.should eq(subject.exposures)
        end

        it 'returns descendant exposures as a priority' do
          subject.expose :name, :email
          child_class = Class.new(subject)
          child_class.expose :name do |_|
            'foo'
          end

          subject.exposures[:name].should_not have_key :proc
          child_class.exposures[:name].should have_key :proc
        end
      end

      context 'register formatters' do
        let(:date_formatter) { lambda {|date| date.strftime('%m/%d/%Y') }}

        it 'registers a formatter' do
          subject.format_with :timestamp, &date_formatter

          subject.formatters[:timestamp].should_not be_nil
        end

        it 'inherits formatters from ancestors' do
          subject.format_with :timestamp, &date_formatter
          child_class = Class.new(subject)

          child_class.formatters.should == subject.formatters
        end

        it 'does not allow registering a formatter without a block' do
          expect{ subject.format_with :foo }.to raise_error(ArgumentError)
        end

        it 'formats an exposure with a registered formatter' do
          subject.format_with :timestamp do |date|
            date.strftime('%m/%d/%Y')
          end

          subject.expose :birthday, :format_with => :timestamp

          model  = { :birthday => Time.gm(2012, 2, 27) }
          subject.new(mock(model)).as_json[:birthday].should == '02/27/2012'
        end
      end
    end

    describe '.with_options' do
      it 'should apply the options to all exposures inside' do
        subject.class_eval do
          with_options(:if => {:awesome => true}) do
            expose :awesome_thing, :using => 'Awesome'
          end
        end

        subject.exposures[:awesome_thing].should == {:if => {:awesome => true}, :using => 'Awesome'}
      end

      it 'should allow for nested .with_options' do
        subject.class_eval do
          with_options(:if => {:awesome => true}) do
            with_options(:using => 'Something') do
              expose :awesome_thing
            end
          end
        end

        subject.exposures[:awesome_thing].should == {:if => {:awesome => true}, :using => 'Something'}
      end

      it 'should allow for overrides' do
        subject.class_eval do
          with_options(:if => {:awesome => true}) do
            expose :less_awesome_thing, :if => {:awesome => false}
          end
        end

        subject.exposures[:less_awesome_thing].should == {:if => {:awesome => false}}
      end
    end

    describe '.represent' do
      it 'returns a single entity if called with one object' do
        subject.represent(Object.new).should be_kind_of(subject)
      end

      it 'returns a single entity if called with a hash' do
        subject.represent(Hash.new).should be_kind_of(subject)
      end

      it 'returns multiple entities if called with a collection' do
        representation = subject.represent(4.times.map{Object.new})
        representation.should be_kind_of Array
        representation.size.should == 4
        representation.reject{|r| r.kind_of?(subject)}.should be_empty
      end

      it 'adds the :collection => true option if called with a collection' do
        representation = subject.represent(4.times.map{Object.new})
        representation.each{|r| r.options[:collection].should be_true}
      end
    end

    describe '.root' do
      context 'with singular and plural root keys' do
        before(:each) do
          subject.root 'things', 'thing'
        end

        context 'with a single object' do
          it 'allows a root element name to be specified' do
            representation = subject.represent(Object.new)
            representation.should be_kind_of Hash
            representation.should have_key 'thing'
            representation['thing'].should be_kind_of(subject)
          end
        end

        context 'with an array of objects' do
          it 'allows a root element name to be specified' do
            representation = subject.represent(4.times.map{Object.new})
            representation.should be_kind_of Hash
            representation.should have_key 'things'
            representation['things'].should be_kind_of Array
            representation['things'].size.should == 4
            representation['things'].reject{|r| r.kind_of?(subject)}.should be_empty
          end
        end

        context 'it can be overridden' do
          it 'can be disabled' do
            representation = subject.represent(4.times.map{Object.new}, :root=>false)
            representation.should be_kind_of Array
            representation.size.should == 4
            representation.reject{|r| r.kind_of?(subject)}.should be_empty
          end
          it 'can use a different name' do
            representation = subject.represent(4.times.map{Object.new}, :root=>'others')
            representation.should be_kind_of Hash
            representation.should have_key 'others'
            representation['others'].should be_kind_of Array
            representation['others'].size.should == 4
            representation['others'].reject{|r| r.kind_of?(subject)}.should be_empty
          end
        end
      end

      context 'with singular root key' do
        before(:each) do
          subject.root nil, 'thing'
        end

        context 'with a single object' do
          it 'allows a root element name to be specified' do
            representation = subject.represent(Object.new)
            representation.should be_kind_of Hash
            representation.should have_key 'thing'
            representation['thing'].should be_kind_of(subject)
          end
        end

        context 'with an array of objects' do
          it 'allows a root element name to be specified' do
            representation = subject.represent(4.times.map{Object.new})
            representation.should be_kind_of Array
            representation.size.should == 4
            representation.reject{|r| r.kind_of?(subject)}.should be_empty
          end
        end
      end

      context 'with plural root key' do
        before(:each) do
          subject.root 'things'
        end

        context 'with a single object' do
          it 'allows a root element name to be specified' do
            subject.represent(Object.new).should be_kind_of(subject)
          end
        end

        context 'with an array of objects' do
          it 'allows a root element name to be specified' do
            representation = subject.represent(4.times.map{Object.new})
            representation.should be_kind_of Hash
            representation.should have_key('things')
            representation['things'].should be_kind_of Array
            representation['things'].size.should == 4
            representation['things'].reject{|r| r.kind_of?(subject)}.should be_empty
          end
        end
      end
    end

    describe '#initialize' do
      it 'takes an object and an optional options hash' do
        expect{ subject.new(Object.new) }.not_to raise_error
        expect{ subject.new }.to raise_error(ArgumentError)
        expect{ subject.new(Object.new, {}) }.not_to raise_error
      end

      it 'has attribute readers for the object and options' do
        entity = subject.new('abc', {})
        entity.object.should == 'abc'
        entity.options.should == {}
      end
    end
  end

  context 'instance methods' do
    
    let(:model){ mock(attributes) }
    
    let(:attributes) { {
      :name => 'Bob Bobson',
      :email => 'bob@example.com',
      :birthday => Time.gm(2012, 2, 27),
      :fantasies => ['Unicorns', 'Double Rainbows', 'Nessy'],
      :friends => [
        mock(:name => "Friend 1", :email => 'friend1@example.com', :fantasies => [], :birthday => Time.gm(2012, 2, 27), :friends => []),
        mock(:name => "Friend 2", :email => 'friend2@example.com', :fantasies => [], :birthday => Time.gm(2012, 2, 27), :friends => [])
      ]
    } }
    
    subject{ fresh_class.new(model) }

    describe '#serializable_hash' do

      it 'does not throw an exception if a nil options object is passed' do
        expect{ fresh_class.new(model).serializable_hash(nil) }.not_to raise_error
      end

      it 'does not blow up when the model is nil' do
        fresh_class.expose :name
        expect{ fresh_class.new(nil).serializable_hash }.not_to raise_error
      end

      it 'does not throw an exception when an attribute is not found on the object' do
        fresh_class.expose :name, :nonexistent_attribute
        expect{ fresh_class.new(model).serializable_hash }.not_to raise_error
      end

      it "does not expose attributes that don't exist on the object" do
        fresh_class.expose :email, :nonexistent_attribute, :name

        res = fresh_class.new(model).serializable_hash
        res.should have_key :email
        res.should_not have_key :nonexistent_attribute
        res.should have_key :name
      end

      it "does not expose attributes that don't exist on the object, even with criteria" do
        fresh_class.expose :email
        fresh_class.expose :nonexistent_attribute, :if => lambda { false }
        fresh_class.expose :nonexistent_attribute2, :if => lambda { true }

        res = fresh_class.new(model).serializable_hash
        res.should have_key :email
        res.should_not have_key :nonexistent_attribute
        res.should_not have_key :nonexistent_attribute2
      end

      it "exposes attributes that don't exist on the object only when they are generated by a block" do
        fresh_class.expose :nonexistent_attribute do |model, _|
          "well, I do exist after all"
        end
        res = fresh_class.new(model).serializable_hash
        res.should have_key :nonexistent_attribute
      end

      it "does not expose attributes that are generated by a block but have not passed criteria" do
        fresh_class.expose :nonexistent_attribute, :proc => lambda {|model, _|
          "I exist, but it is not yet my time to shine"
        }, :if => lambda { |model, _| false }
        res = fresh_class.new(model).serializable_hash
        res.should_not have_key :nonexistent_attribute
      end

      context '#serializable_hash' do

        module EntitySpec
          class EmbeddedExample
            def serializable_hash(opts = {})
              { :abc => 'def' }
            end
          end
          class EmbeddedExampleWithMany
            def name
              "abc"
            end
            def embedded
              [ EmbeddedExample.new, EmbeddedExample.new ]
            end
          end
          class EmbeddedExampleWithOne
            def name
              "abc"
            end
            def embedded
              EmbeddedExample.new
            end
          end
        end
      
        it 'serializes embedded objects which respond to #serializable_hash' do
          fresh_class.expose :name, :embedded
          presenter = fresh_class.new(EntitySpec::EmbeddedExampleWithOne.new)
          presenter.serializable_hash.should == {:name => "abc", :embedded => {:abc => "def"}}
        end

        it 'serializes embedded arrays of objects which respond to #serializable_hash' do
          fresh_class.expose :name, :embedded
          presenter = fresh_class.new(EntitySpec::EmbeddedExampleWithMany.new)
          presenter.serializable_hash.should == {:name => "abc", :embedded => [{:abc => "def"}, {:abc => "def"}]}
        end
        
      end
      
    end

    describe '#value_for' do
      before do
        fresh_class.class_eval do
          expose :name, :email
          expose :friends, :using => self
          expose :computed do |_, options|
            options[:awesome]
          end

          expose :birthday, :format_with => :timestamp

          def timestamp(date)
            date.strftime('%m/%d/%Y')
          end

          expose :fantasies, :format_with => lambda {|f| f.reverse }
        end
      end

      it 'passes through bare expose attributes' do
        subject.send(:value_for, :name).should == attributes[:name]
      end

      it 'instantiates a representation if that is called for' do
        rep = subject.send(:value_for, :friends)
        rep.reject{|r| r.is_a?(fresh_class)}.should be_empty
        rep.first.serializable_hash[:name].should == 'Friend 1'
        rep.last.serializable_hash[:name].should == 'Friend 2'
      end

      context 'child representations' do
        it 'disables root key name for child representations' do
        
          module EntitySpec
            class FriendEntity < Grape::Entity
              root 'friends', 'friend'
              expose :name, :email
            end
          end
          
          fresh_class.class_eval do
            expose :friends, :using => EntitySpec::FriendEntity
          end
          
          rep = subject.send(:value_for, :friends)
          rep.should be_kind_of Array
          rep.reject{|r| r.is_a?(EntitySpec::FriendEntity)}.should be_empty
          rep.first.serializable_hash[:name].should == 'Friend 1'
          rep.last.serializable_hash[:name].should == 'Friend 2'
        end

        it 'passes through custom options' do
          module EntitySpec
            class FriendEntity < Grape::Entity
              root 'friends', 'friend'
              expose :name
              expose :email, :if => { :user_type => :admin }
            end
          end
          
          fresh_class.class_eval do
            expose :friends, :using => EntitySpec::FriendEntity
          end
          
          rep = subject.send(:value_for, :friends)
          rep.should be_kind_of Array
          rep.reject{|r| r.is_a?(EntitySpec::FriendEntity)}.should be_empty
          rep.first.serializable_hash[:email].should be_nil
          rep.last.serializable_hash[:email].should be_nil

          rep = subject.send(:value_for, :friends, { :user_type => :admin })
          rep.should be_kind_of Array
          rep.reject{|r| r.is_a?(EntitySpec::FriendEntity)}.should be_empty
          rep.first.serializable_hash[:email].should == 'friend1@example.com'
          rep.last.serializable_hash[:email].should == 'friend2@example.com'
        end

        it 'ignores the :collection parameter in the source options' do
          module EntitySpec
            class FriendEntity < Grape::Entity
              root 'friends', 'friend'
              expose :name
              expose :email, :if => { :collection => true }
            end
          end
          
          fresh_class.class_eval do
            expose :friends, :using => EntitySpec::FriendEntity
          end
          
          rep = subject.send(:value_for, :friends, { :collection => false })
          rep.should be_kind_of Array
          rep.reject{|r| r.is_a?(EntitySpec::FriendEntity)}.should be_empty
          rep.first.serializable_hash[:email].should == 'friend1@example.com'
          rep.last.serializable_hash[:email].should == 'friend2@example.com'
        end

      end

      it 'calls through to the proc if there is one' do
        subject.send(:value_for, :computed, :awesome => 123).should == 123
      end

      it 'returns a formatted value if format_with is passed' do
        subject.send(:value_for, :birthday).should == '02/27/2012'
      end

      it 'returns a formatted value if format_with is passed a lambda' do
        subject.send(:value_for, :fantasies).should == ['Nessy', 'Double Rainbows', 'Unicorns']
      end
    end

    describe '#documentation' do
      it 'returns an empty hash is no documentation is provided' do
        fresh_class.expose :name

        subject.documentation.should == {}
      end

      it 'returns each defined documentation hash' do
        doc = {:type => "foo", :desc => "bar"}
        fresh_class.expose :name, :documentation => doc
        fresh_class.expose :email, :documentation => doc
        fresh_class.expose :birthday

        subject.documentation.should == {:name  => doc, :email => doc}
      end
    end

    describe '#key_for' do
      it 'returns the attribute if no :as is set' do
        fresh_class.expose :name
        subject.send(:key_for, :name).should == :name
      end

      it 'returns a symbolized version of the attribute' do
        fresh_class.expose :name
        subject.send(:key_for, 'name').should == :name
      end

      it 'returns the :as alias if one exists' do
        fresh_class.expose :name, :as => :nombre
        subject.send(:key_for, 'name').should == :nombre
      end
    end

    describe '#conditions_met?' do
      it 'only passes through hash :if exposure if all attributes match' do
        exposure_options = {:if => {:condition1 => true, :condition2 => true}}

        subject.send(:conditions_met?, exposure_options, {}).should be_false
        subject.send(:conditions_met?, exposure_options, :condition1 => true).should be_false
        subject.send(:conditions_met?, exposure_options, :condition1 => true, :condition2 => true).should be_true
        subject.send(:conditions_met?, exposure_options, :condition1 => false, :condition2 => true).should be_false
        subject.send(:conditions_met?, exposure_options, :condition1 => true, :condition2 => true, :other => true).should be_true
      end

      it 'looks for presence/truthiness if a symbol is passed' do
        exposure_options = {:if => :condition1}

        subject.send(:conditions_met?, exposure_options, {}).should be_false
        subject.send(:conditions_met?, exposure_options, {:condition1 => true}).should be_true
        subject.send(:conditions_met?, exposure_options, {:condition1 => false}).should be_false
        subject.send(:conditions_met?, exposure_options, {:condition1 => nil}).should be_false
      end

      it 'looks for absence/falsiness if a symbol is passed' do
        exposure_options = {:unless => :condition1}

        subject.send(:conditions_met?, exposure_options, {}).should be_true
        subject.send(:conditions_met?, exposure_options, {:condition1 => true}).should be_false
        subject.send(:conditions_met?, exposure_options, {:condition1 => false}).should be_true
        subject.send(:conditions_met?, exposure_options, {:condition1 => nil}).should be_true
      end

      it 'only passes through proc :if exposure if it returns truthy value' do
        exposure_options = {:if => lambda{|_,opts| opts[:true]}}

        subject.send(:conditions_met?, exposure_options, :true => false).should be_false
        subject.send(:conditions_met?, exposure_options, :true => true).should be_true
      end

      it 'only passes through hash :unless exposure if any attributes do not match' do
        exposure_options = {:unless => {:condition1 => true, :condition2 => true}}

        subject.send(:conditions_met?, exposure_options, {}).should be_true
        subject.send(:conditions_met?, exposure_options, :condition1 => true).should be_false
        subject.send(:conditions_met?, exposure_options, :condition1 => true, :condition2 => true).should be_false
        subject.send(:conditions_met?, exposure_options, :condition1 => false, :condition2 => true).should be_false
        subject.send(:conditions_met?, exposure_options, :condition1 => true, :condition2 => true, :other => true).should be_false
        subject.send(:conditions_met?, exposure_options, :condition1 => false, :condition2 => false).should be_true
      end

      it 'only passes through proc :unless exposure if it returns falsy value' do
        exposure_options = {:unless => lambda{|_,options| options[:true] == true}}

        subject.send(:conditions_met?, exposure_options, :true => false).should be_true
        subject.send(:conditions_met?, exposure_options, :true => true).should be_false
      end
    end

    describe '::DSL' do
      subject{ Class.new }

      it 'creates an Entity class when called' do
        subject.should_not be_const_defined :Entity
        subject.send(:include, Grape::Entity::DSL)
        subject.should be_const_defined :Entity
      end

      context 'pre-mixed' do
        before{ subject.send(:include, Grape::Entity::DSL) }

        it 'is able to define entity traits through DSL' do
          subject.entity do
            expose :name
          end

          subject.entity_class.exposures.should_not be_empty
        end

        it 'is able to expose straight from the class' do
          subject.entity :name, :email
          subject.entity_class.exposures.size.should == 2
        end

        it 'is able to mix field and advanced exposures' do
          subject.entity :name, :email do
            expose :third
          end
          subject.entity_class.exposures.size.should == 3
        end

        context 'instance' do
          let(:instance){ subject.new }

          describe '#entity' do
            it 'is an instance of the entity class' do
              instance.entity.should be_kind_of(subject.entity_class)
            end

            it 'has an object of itself' do
              instance.entity.object.should == instance
            end

            it 'should instantiate with options if provided' do
              instance.entity(:awesome => true).options.should == {:awesome => true}
            end
          end
        end
      end
    end
  end
end
