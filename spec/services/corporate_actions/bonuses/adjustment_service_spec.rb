require 'rails_helper'

RSpec.describe CorporateActions::Bonuses::AdjustmentService do
  let(:stock) { create(:stock) }

  describe "#call" do
    context "when no bonuses exist" do
      it "returns original quantity" do
        result = described_class.new(
          stock: stock,
          quantity: 10
        ).call

        expect(result).to eq(10)
      end
    end

    context "with 1:1 bonus" do
      before do
        create(:bonus,
               stock: stock,
               ratio_from: 1,
               ratio_to: 1,
               ex_date: Date.new(2023, 1, 1))
      end

      it "doubles the quantity" do
        result = described_class.new(
          stock: stock,
          quantity: 10,
          as_of: Date.new(2023, 2, 1)
        ).call

        expect(result).to eq(20)
      end
    end

    context "with 2:1 bonus" do
      before do
        create(:bonus,
               stock: stock,
               ratio_from: 1,
               ratio_to: 2,
               ex_date: Date.new(2023, 1, 1))
      end

      it "adds double shares" do
        result = described_class.new(
          stock: stock,
          quantity: 10,
          as_of: Date.new(2023, 2, 1)
        ).call

        expect(result).to eq(30) # 10 + 20
      end
    end

    context "with multiple bonuses" do
      before do
        create(:bonus, stock: stock, ratio_from: 1, ratio_to: 1, ex_date: Date.new(2023,1,1))
        create(:bonus, stock: stock, ratio_from: 1, ratio_to: 1, ex_date: Date.new(2023,2,1))
      end

      it "applies bonuses sequentially" do
        result = described_class.new(
          stock: stock,
          quantity: 10,
          as_of: Date.new(2023, 3, 1)
        ).call

        expect(result).to eq(40) # 10 → 20 → 40
      end
    end

    context "when bonus is after as_of date" do
      before do
        create(:bonus,
               stock: stock,
               ratio_from: 1,
               ratio_to: 1,
               ex_date: Date.new(2024, 1, 1))
      end

      it "does not apply bonus" do
        result = described_class.new(
          stock: stock,
          quantity: 10,
          as_of: Date.new(2023, 1, 1)
        ).call

        expect(result).to eq(10)
      end
    end
  end
end
