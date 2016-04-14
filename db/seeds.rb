Post.destroy_all
User.destroy_all

User.create!({
  name: 'Lester Tester',
  email: 'test@user.com',
  password: 'test1234',
  password_confirmation: 'test1234'
})

100.times do
  PublicPost.create!(
    title: Faker::Lorem.sentence,
    body: Faker::Lorem.paragraphs.join(' ')
  )

  PrivatePost.create!(
    title: Faker::Lorem.sentence,
    body: Faker::Lorem.paragraphs.join(' ')
  )
end
