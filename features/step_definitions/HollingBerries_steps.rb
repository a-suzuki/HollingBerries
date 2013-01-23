#encoding: utf-8

$: << 'D:\共有\HollingBerries'

require 'HollingBerries.rb'

もし /^アプリケーションを実行した$/ do
  main
  f = open 'pricefile.txt'
  @actual = f.read
  f.close
end

ならば /^出力結果が正しいこと$/ do
  @actual.should eq open('pricefile_original.txt').read
end