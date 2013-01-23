#encoding: utf-8
$: << File.dirname(__FILE__)

require 'rspec'
require 'HollingBerries'
require 'date'

# TODO 説明変数使え。仕入れ業者とか。

describe "商品種別から利幅を求める" do
  describe "通常の業者(1)の場合" do
    it "1100(リンゴ)は40%" do
      get_margin(1, 1100).should be_within(0.01).of(0.4)
    end

    it "1200(バナナ)は35%" do
      get_margin(1, 1200).should be_within(0.01).of(0.35)
    end

    it "1300(ベリー)は55%" do
      get_margin(1, 1300).should be_within(0.01).of(0.55)
    end

    it "0(その他)は50%" do
      get_margin(1, 0).should be_within(0.01).of(0.5)
    end
  end
  describe "プレミアム業者の場合" do
    it "1100(リンゴ)は50%" do
      get_margin(219, 1100).should be_within(0.01).of(0.5)
    end

    it "1200(バナナ)は45%" do
      get_margin(219, 1200).should be_within(0.01).of(0.45)
    end

    it "1300(ベリー)は65%" do
      get_margin(204, 1300).should be_within(0.01).of(0.65)
    end

    it "0(その他)は60%" do
      get_margin(204, 0).should be_within(0.01).of(0.60)
    end
  end
end


describe "商品コードから果物の種類を取得する" do
  it "1100はリンゴ" do
    get_product_type(1100).should eq "リンゴ"
  end

  it "1199はリンゴ" do
    get_product_type(1199).should eq "リンゴ"
  end

  it "1200はバナナ" do
    get_product_type(1200).should eq "バナナ"
  end

  it "1299はバナナ" do
    get_product_type(1299).should eq "バナナ"
  end

  it "1300はベリー" do
    get_product_type(1300).should eq "ベリー"
  end

  it "1399はベリー" do
    get_product_type(1399).should eq "ベリー"
  end

  it "0はその他" do
    get_product_type(0).should eq "その他"
  end

  it "1099はその他" do
    get_product_type(1099).should eq "その他"
  end

  it "1400はその他" do
    get_product_type(1400).should eq "その他"
  end

  it "2000はその他" do
    get_product_type(2000).should eq "その他"
  end

end

describe "単位をRドルに変換する" do
  it "100は1" do
    to_R_dollar(100).should eq 1
  end

  it "50は0.5" do
    to_R_dollar(50).should eq 0.5
  end
end

describe "仕入れ値から売値を計算する" do
  describe "通常の業者(1)の場合" do
    describe "製品がリンゴの場合" do
      it "100は1.4" do
        get_selling_price(1, 1100, 100).should eq 1.4
      end
    end

    describe "製品がバナナの場合" do
      it "100は1.35" do
        get_selling_price(1, 1200, 100).should eq 1.35
      end
    end

    describe "製品がベリーの場合" do
      it "100は1.55" do
        get_selling_price(1, 1300, 100).should eq 1.55
      end
    end

    describe "製品がその他の場合" do
      it "100は1.5" do
        get_selling_price(1, 0, 100).should eq 1.5
      end

      it "1は0.015" do
        get_selling_price(1, 0, 1).should eq 0.015
      end
    end
  end
  describe "ダメ業者の場合" do
    describe "スーザン(32)で製品がリンゴの場合" do
      it "1000は12" do
        get_selling_price(32, 1100, 1000).should eq 12
      end
    end

    describe "スーザン(32)で製品がバナナの場合" do
      it "1000は11.5" do
        get_selling_price(32, 1200, 1000).should eq 11.5
      end
    end

    describe "スーザン(32)で製品がベリーの場合" do
      it "1000は13.5" do
        get_selling_price(32, 1300, 1000).should eq 13.5
      end
    end

    describe "スーザン(32)で製品がその他の場合" do
      it "1000は13" do
        get_selling_price(32, 0, 1000).should eq 13
      end
    end

    describe "トゲザネス（101）で製品がその他でペナルティの結果がマイナスになる場合" do
      it "100は0" do
        get_selling_price(101, 0, 100).should eq 0
      end
    end
  end

  describe "プレミアム業者の場合" do
    describe "プロミス(219)で製品がリンゴの場合" do
      it "1609は25" do
        get_selling_price(219, 1100, 1609).should eq 25
      end
    end
    describe "カーレル(204)で製品がベリーの場合" do
      it "2894は48" do
        get_selling_price(204, 1381, 2894).should eq 48
      end
    end
  end
end

describe "SubplierIDに応じたペナルティ日数を求める" do
  it "スーザン(32)ならR2" do
    get_penalty_price(32).should eq 2
  end
  it "トゲザネス(101)ならR2" do
    get_penalty_price(101).should eq 2
  end
  it "その他(5)ならR0" do
    get_penalty_price(5).should eq 0
  end
end

describe "SubplierIDに応じたペナルティ日数を求める" do
  it "スーザン(32)なら3日" do
    get_penalty_days(32).should eq 3
  end
  it "トゲザネス(101)なら3日" do
    get_penalty_days(101).should eq 3
  end
  it "その他(5)なら0日" do
    get_penalty_days(5).should eq 0
  end
end

  describe "商品種別から販売期限を求める" do
    describe "通常の業者の場合" do
      describe "製品がリンゴの場合" do
        it "1100(リンゴ)は2週間後" do
          input_date = Date::new(2012, 1, 10)
          expected_date = Date::new(2012, 1, 24)
          get_limit_date(1, 1100,  input_date).should eq  expected_date
        end 
      end

      describe "製品がバナナの場合" do
        it "1200(バナナ)は5日後" do
          input_date = Date::new(2012, 1, 10)
          expected_date = Date::new(2012, 1, 15)
          get_limit_date(1, 1200,  input_date).should eq  expected_date
        end 
      end

      describe "製品がベリーの場合" do
        it "1300(ベリー)は一週間後" do
          input_date = Date::new(2012, 1, 10)
          expected_date = Date::new(2012, 1, 17)
          get_limit_date(1, 1300,  input_date).should eq  expected_date
        end 
      end

      describe "製品がその他の場合" do
        it "1400(その他)は一週間後" do
          input_date = Date::new(2012, 1, 10)
          expected_date = Date::new(2012, 1, 17)
          get_limit_date(1, 1400,  input_date).should eq  expected_date
        end 
      end
  end
  describe "ダメ業者の場合" do
      it "スーザン(32)で1100(リンゴ)は2週間マイナス3日後（11日後）" do
        input_date = Date::new(2012, 1, 10)
        expected_date = Date::new(2012, 1, 21)
        get_limit_date(32, 1100,  input_date).should eq  expected_date
      end

      it "スーザン(32)で1200(バナナ)は5日後マイナス3日後（2日後）" do
          input_date = Date::new(2012, 1, 10)
          expected_date = Date::new(2012, 1, 12)
          get_limit_date(32, 1200,  input_date).should eq  expected_date
        end

      it "スーザン(32)で1300(ベリー)は一週間後マイナス3日後（4日後）" do
          input_date = Date::new(2012, 1, 10)
          expected_date = Date::new(2012, 1, 14)
          get_limit_date(32, 1300,  input_date).should eq  expected_date
      end

      it "スーザン(32)で1400(その他)は一週間後マイナス3日後（4日後）" do
          input_date = Date::new(2012, 1, 10)
          expected_date = Date::new(2012, 1, 14)
          get_limit_date(32, 1400,  input_date).should eq  expected_date
      end
    end
end

describe "説明を31文字にする" do
  it "入力が1文字だと1文字になる" do
    str = "1"
    cut_description(str).should eq str
  end

  it "入力が31文字だと31文字になる" do
    str = "1234567890123456789012345678901"
    cut_description(str).should eq str
  end

  it "入力が31文字より長いと31文字になる" do
    str = "12345678901234567890123456789012"
    cut_description(str).should eq str[0..30]
  end
end