# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en  
require 'common'


require 'lims-laboratory-app/laboratory/sample'
require 'lims-laboratory-app/laboratory/snp_assay'
require 'lims-laboratory-app/laboratory/oligo'
require 'lims-core/resource'

module Lims::LaboratoryApp
  module Laboratory
    # An aliquot represent the fraction of identical chemical substance inside a receptacle.
    # it should have:
    # 1. A receptacle
    # 1. A quantity  => volume, weight, moles?
    # 2. An owner (Order?)
    # 3. One or more constituents (sample, tags).
    # 4. A type/shape (gel, library, sample  etc...)
    # Constituents inside an aliquot are bound together, i.e. :
    # - "mixing" sample and tag in a tube without any processing will probably results
    # in a receptacle containing two aliquots, one representing the tag and the other
    # one the sample.
    # - "tagging" a sample with a oligo will result in a receptacle containing one aliquot
    #   representing the tagged sample (the oligo and the sample are bound together).
    # At the moment, rather than allowing an aliquot to have many constituents (in a free form way),
    # an aliquot can be formed of at least a {Laboratory::Sample sample}, a {Laboratory::Oligo tag} and  or a {Laboratory::BaitLibrary bait library}.
    class Aliquot
      include Lims::Core::Resource
      attribute :sample, Sample
      attribute :snp_assay, SnpAssay
      attribute :tag, Oligo
      # @todo add a unit to quantity
      attribute :quantity, Numeric, :required=> true, :gte => 0

      # the form of the chemical substance, like library, sample etc ...
      attribute :type, String # Subclass ?
      # Contain extra data which are not stored in S2 database but broadcasted on the message bus
      attribute :out_of_bounds, Hash, :required => false, :default => {}

      #validates_presence_of :quantity
      #validates_numericalness_of :quantity, :gte => 0

      # As out_of_bounds parameter is not persisted and saved in the database
      # we remove it from the attributes when it is not used. So, the return
      # json in the api does not mention it.
      def attributes
        super.tap do |attr|
          attr.delete(:out_of_bounds) if out_of_bounds.empty?
        end
      end

      # Take a percentage of an aliquot
      # and remove the corresponding quantity
      # 1 (100%) remove everything from the current aliquot
      # nil won't remove anything nor set a quantity on the returned aliquot
      # @param [Float, nil] fraction
      # @return [Aliquot]
      def take_fraction(fraction)
        new = self.class.new(attributes)
        if quantity && fraction
          new_quantity = quantity*fraction
          self.quantity -= new_quantity
          new.quantity = new_quantity
        else
          new.quantity= nil
        end
        return new
      end

      def ===(other)
        to_exclude = [:quantity]
        a, b = [self, other].map { |a| a.attributes - to_exclude }
        a == b
      end


      # The following methods should be in subclass
      # It will need to be move in subclass if we implement subclasses
      module Dimension
        # Dimension
        Volume = :volume
        Mass = :mass
        AmountOfSubstance = :amount_of_substance

        DimensionToUnit = { Volume => "ul", Mass => "mg", AmountOfSubstance => "mole" }

        # Type
        Solvent = "solvent"
      end
      include Dimension

      # describe what kind of measure the quantity refers to.
      # @return [String]
      def self.dimension(type)
        # By default, dimension are AmountOfSubstance except for
        # solvent which are by default liquid, therefore volume.
        case type
        when Solvent then Volume
        else AmountOfSubstance
        end
      end

      def dimension
        self.class.dimension(type)
      end

      # The unit in which the quantity is store.
      # For example, volume are stored in microlittre
      # so the unit will be ul.
      def self.unit(type)
        DimensionToUnit[dimension(type)]
      end

      def unit
        self.class.unit(type)
      end

      # add the specified amount to the current aliquot quantity, can be nil
      # @param [Float,Nil] quantity
      def increase_quantity(quantity)
        new_quantity = self.class.add_quantity(self.quantity, quantity)
        self.quantity = new_quantity && [0, new_quantity].max

      end

      # add to quantities, work out nil number
      # @param [Number, Nil] q1
      # @param [Number, Nil] q2
      # @return [Number, Nil]
      def self.add_quantity(q1, q2)
        q1 && q2 ? q1+q2 : q1 || q2
      end
    end
  end
end
