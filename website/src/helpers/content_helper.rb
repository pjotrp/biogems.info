module ContentHelper
  def by_popularity
    yield 1,"one"
    yield 2,"two"
    yield 3,"three"
  end
end
