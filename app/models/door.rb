class Door < ActiveRecord::Base
  cattr_accessor :xml_rpc_uri
  set_table_name :door
  validates_presence_of :name

  has_many :door_accesses
  has_many :access_groups, :through => :door_accesses

  before_create :set_default_unlocked

  def set_default_unlocked
    self.default_unlocked ||= 'N'  
  end

  def display_name
    name.gsub('_',' ')
  end

  include HTTParty
  base_uri File.read('config/xml_rpc.txt').strip

  def self.open(door_name)
    raise "no door name given" if door_name.empty?
    self.post('/xml-rpc/', :body => open_door_body(door_name))
  end

  def self.open_door_body(door_name)
    return <<-XML.strip
    <?xml version="1.0"?>
    <methodCall>
       <methodName>DoorControl.openDoor</methodName>
       <params>
          <param>
             <value><string>#{door_name}</string></value>
           </param>
        </params>
    </methodCall>
    XML
  end 
end
