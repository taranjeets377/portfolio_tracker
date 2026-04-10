require 'rails_helper'

RSpec.describe CorporateActions::StockSplits::AdjustmentService do
  let(:stock) { create(:stock) }

  describe "#call" do
    context "when no splits exist" do
      it "returns original quantity and avg_price" do
        result = described_class.new(
          stock: stock,
          quantity: 10,
          avg_price: 100
        ).call

        expect(result[:quantity]).to eq(10)
        expect(result[:avg_price]).to eq(100)
      end
    end

    context "with a 1:5 split" do
      before do
        create(:stock_split,
               stock: stock,
               ratio_from: 1,
               ratio_to: 5,
               ex_date: Date.new(2023, 1, 1))
      end

      it "adjusts quantity and avg_price correctly" do
        result = described_class.new(
          stock: stock,
          quantity: 10,
          avg_price: 100,
          as_of: Date.new(2023, 2, 1)
        ).call

        expect(result[:quantity]).to eq(50)
        expect(result[:avg_price]).to eq(20)
      end
    end

    context "with multiple splits" do
      before do
        create(:stock_split, stock: stock, ratio_from: 1, ratio_to: 5, ex_date: Date.new(2023, 1, 1))
        create(:stock_split, stock: stock, ratio_from: 2, ratio_to: 1, ex_date: Date.new(2024, 1, 1))
      end

      it "applies splits in chronological order" do
        result = described_class.new(
          stock: stock,
          quantity: 10,
          avg_price: 100,
          as_of: Date.new(2025, 1, 1)
        ).call

        expect(result[:quantity]).to eq(25) # 10 → 50 → 25
        expect(result[:avg_price]).to eq(40) # 100 → 20 → 40
      end
    end

    context "when split is after as_of date" do
      before do
        create(:stock_split,
               stock: stock,
               ratio_from: 1,
               ratio_to: 5,
               ex_date: Date.new(2024, 1, 1)
              )
      end

      it "does not apply the split" do
        result = described_class.new(
          stock: stock,
          quantity: 10,
          avg_price: 100,
          as_of: Date.new(2023, 1, 1)
        ).call

        expect(result[:quantity]).to eq(10)
        expect(result[:avg_price]).to eq(100)
      end
    end

    context "with reverse split 2:1" do
      before do
        create(:stock_split,
          stock: stock,
          ratio_from: 2,
          ratio_to: 1,
          ex_date: Date.new(2023,1,1)
        )
      end

      it "reduces quantity and increases avg price" do
        result = described_class.new(
          stock: stock,
          quantity: 10,
          avg_price: 100,
          as_of: Date.new(2023,2,1)
        ).call

        expect(result[:quantity]).to eq(5)
        expect(result[:avg_price]).to eq(200)
      end
    end

    context "with split and sell interaction" do
      it "correctly adjusts quantity after sell and split" do
        # Base quantity after sell = 8
        # After 1:5 split → 40

        create(:stock_split,
          stock: stock,
          ratio_from: 1,
          ratio_to: 5,
          ex_date: Date.new(2023,1,1)
        )

        result = described_class.new(
          stock: stock,
          quantity: 8, # simulate post-sell quantity
          avg_price: 100,
          as_of: Date.new(2023,2,1)
        ).call

        expect(result[:quantity]).to eq(40)
      end
    end
  end
end
