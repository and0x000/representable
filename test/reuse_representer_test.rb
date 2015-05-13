require "test_helper"

module Representable
  module Cached
    def representable_mapper(*)
      @mapper ||= super
    end

    # replace represented for each property in this representer.
    # DISCUSS: not sure if we need to replace self and user_options.
    def update!(represented, user_options)
      representable_mapper.bindings.each do |binding|
        binding.update!(represented, self, user_options)
        # binding.instance_variable_set(:@represented, represented)
        # binding.instance_variable_set(:@exec_context, represented)
      end
    end
  end
end


# TODO: also test with feature(Cached)

class SongRepresenter < Representable::Decorator
  include Representable::Hash
  include Representable::Cached

  property :title
end

class AlbumRepresenter < Representable::Decorator
  include Representable::Hash
  include Representable::Cached

  property :name
  collection :songs, decorator: SongRepresenter
end



module Model
  Song  = Struct.new(:title, :composer)
  Album = Struct.new(:name, :songs, :artist)
  Artist = Struct.new(:name, :hidden_taste)
end

song  = Model::Song.new("Jailbreak")
song2 = Model::Song.new("Southbound")
album = Model::Album.new("Live And Dangerous", [song, song2, Model::Song.new("Emerald")])

album2 = Model::Album.new("Louder And Even More Dangerous", [song2, song])



representer = AlbumRepresenter.new(album)

puts representer.to_hash # called in Deserializer/Serializer

require "pp"
# puts "???"
# pp representer

representer.update!(album2, {})

puts "???"

puts representer.to_hash # called in Deserializer/Serializer

puts ".."
puts "."

definition = SongRepresenter.representable_attrs.get(:title)

binding = Representable::Hash::Binding.build(definition, song, Object)

puts "++"
puts "++ #{binding.compile_fragment({})}"

binding.instance_variable_set(:@represented, song2)
binding.instance_variable_set(:@exec_context, song2)

puts "++ #{binding.compile_fragment({})}"
