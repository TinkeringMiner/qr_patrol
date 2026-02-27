Navigator.pushNamed(
  context,
  '/guardDashboard',
  arguments: {
    'guardId': loggedInUser.id,
    'guardName': loggedInUser.name,
    'coyNumber': loggedInUser.coyNumber,
  },
);