require 'test_helper'

class Repo::Resolvers::DomainResolverTest < ActiveSupport::TestCase
  include LoggingCommonMock

  def setup
    @resolver = Repo::Resolvers::DomainResolver.new
  end

  test 'priority is highest' do
    assert_equal 100000, @resolver.priority
  end

  test 'resolve updates input when parsed_input nil and domain resolves' do
    context = Repo::RepoResolverContext.new('example.com')
    context.stubs(:parsed_input).returns(nil)
    @resolver.stubs(:resolvable_domain?).returns(true)
    @resolver.resolve(context)
    assert_equal 'https://example.com/', context.input
  end

  test 'resolve updates input for localhost and docker hosts with ports' do
    @resolver.stubs(:resolvable_domain?).returns(true)
    ['localhost:8080', 'host.docker.internal:8000'].each do |input|
      context = Repo::RepoResolverContext.new(input)
      context.stubs(:parsed_input).returns(nil)
      @resolver.resolve(context)
      assert_equal "https://#{input}/", context.input
    end
  end

  test 'resolve does nothing when parsed_input present' do
    context = Repo::RepoResolverContext.new('https://example.com')
    @resolver.stubs(:resolvable_domain?).returns(true)
    @resolver.resolve(context)
    assert_nil context.object_url
  end

  test 'resolve does not update input for unresolvable domain' do
    context = Repo::RepoResolverContext.new('notadomain.localxyz')
    context.stubs(:parsed_input).returns(nil)
    @resolver.stubs(:resolvable_domain?).returns(false)
    @resolver.resolve(context)
    assert_equal 'notadomain.localxyz', context.input
  end

  test 'resolvable_domain? returns false when DNS lookup fails' do
    Resolv.expects(:getaddress).raises(Resolv::ResolvError)
    refute @resolver.send(:resolvable_domain?, 'bad.example')
  end
end
