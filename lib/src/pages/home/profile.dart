import 'package:bugheist/src/global/variables.dart';
import 'package:bugheist/src/util/api/issues_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/issuechip.dart';
import '../../models/issue_model.dart';
import '../../models/user_model.dart';
import '../../providers/authstate_provider.dart';
import '../../routes/routing.dart';

/// Page that displays the stats of a user registered on BugHeist,
/// shows dummy data for Guest login.
class UserProfile extends ConsumerStatefulWidget {
  const UserProfile({
    Key? key,
    User? user,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserProfileState();
}

class _UserProfileState extends ConsumerState<UserProfile> {
  late Future<List<Issue>?> getUpvoteList;
  late Future<List<Issue>?> getSavedList;

  Future<List<Issue>?> getIssueList(List<int>? idList) async {
    List<Issue>? issueList = null;
    try {
      if (idList != null) {
        issueList = [];
        for (int id in idList) {
          Issue? issue = await IssueApiClient.getIssueById(id);
          if (issue != null) issueList.add(issue);
        }
      }
    } catch (e) {}
    return issueList;
  }

  Future<void> logout() async {
    await ref.read(authStateNotifier.notifier).logout();
  }

  Widget buildUpvotedIssues(Size size, List<Issue>? issueList) {
    if (issueList != null && issueList.length > 0) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF737373), width: 0.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: size.width, maxHeight: 0.75 * size.height),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: issueList.length,
              itemBuilder: (context, index) {
                Issue issue = issueList[index];
                return ListTile(
                  leading: Text("#${issue.id}"),
                  title: Text(
                    issue.description.substring(0, 24) + "...",
                  ),
                  trailing: IssueStatusChip(
                    issue: issue,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      RouteManager.issueDetailPage,
                      arguments: issue,
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        width: size.width,
        height: 0.3 * size.height,
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF737373), width: 0.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            "No issues Upvoted",
            style: GoogleFonts.aBeeZee(
              textStyle: TextStyle(
                color: Color(0xFF737373),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget buildSavedIssues(Size size, List<Issue>? issueList) {
    if (issueList != null && issueList.length > 0) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF737373), width: 0.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: size.width, maxHeight: 0.75 * size.height),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: issueList.length,
              itemBuilder: (context, index) {
                Issue issue = issueList[index];
                return ListTile(
                  leading: Text("#${issue.id}"),
                  title: Text(
                    issue.description.substring(0, 24) + "...",
                  ),
                  trailing: IssueStatusChip(
                    issue: issue,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      RouteManager.issueDetailPage,
                      arguments: issue,
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        width: size.width,
        height: 0.3 * size.height,
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF737373), width: 0.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            "No issues Saved",
            style: GoogleFonts.aBeeZee(
              textStyle: TextStyle(
                color: Color(0xFF737373),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    getUpvoteList = getIssueList(
      currentUser!.upvotedIssueId!.length > 0
          ? currentUser!.upvotedIssueId!
          : null,
    );
    getSavedList = getIssueList(
      currentUser!.savedIssueId!.length > 0 ? currentUser!.savedIssueId! : null,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(currentUser!.username!),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                RouteManager.welcomePage,
              );
              logout();
            },
            icon: Icon(Icons.power_settings_new_rounded),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF737373).withOpacity(0.125),
              Colors.transparent,
            ],
          ),
        ),
        width: size.width,
        height: size.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: size.width,
                height: 0.25 * size.height,
                decoration: BoxDecoration(
                  color: Color(0xFFDC4654),
                  image: DecorationImage(
                    image: NetworkImage(currentUser!.pfpLink!),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [BoxShadow(blurRadius: 7.0, color: Colors.black)],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                width: size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser!.username!,
                      style: GoogleFonts.ubuntu(
                        textStyle: TextStyle(
                          color: Color(0xFFDC4654),
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Text(
                      '#${currentUser!.id!}',
                      style: GoogleFonts.aBeeZee(
                        textStyle: TextStyle(
                          color: Color(0xFF737373).withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5.0,
                        ),
                        child: Text(
                          (currentUser!.description != null)
                              ? currentUser!.description!
                              : "No description, write one!",
                          style: GoogleFonts.aBeeZee(
                            textStyle: TextStyle(
                              color: Color(0xFF737373),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      child: (currentUser!.following != null)
                          ? TextButton(
                              onPressed: () {},
                              child: Text(
                                currentUser!.following!.length.toString() +
                                    " following",
                                style: GoogleFonts.aBeeZee(
                                  textStyle: TextStyle(
                                    color: Color(0xFFDC4654),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                    Divider(
                      thickness: 2,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_repeat,
                          color: Color(0xFF737373),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 8,
                          ),
                          child: Text(
                            "Recent Activity",
                            style: GoogleFonts.ubuntu(
                              textStyle: TextStyle(
                                color: Color(0xFF737373),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(
                            Icons.report_problem_rounded,
                            color: Color(0xFFDC4654),
                          ),
                        ),
                        Text(
                          "Upvoted Issues",
                          style: GoogleFonts.ubuntu(
                            textStyle: TextStyle(
                              color: Color(0xFFDC4654),
                              fontSize: 17.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Color(0xFFDC4654),
                      thickness: 2,
                    ),
                    FutureBuilder<List<Issue>?>(
                      future: getUpvoteList,
                      builder: ((context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            width: size.width,
                            height: 0.3 * size.height,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF737373),
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return buildUpvotedIssues(size, snapshot.data);
                        }
                      }),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(
                            Icons.bookmark_outlined,
                            color: Color(0xFFDC4654),
                          ),
                        ),
                        Text(
                          "Saved Issues",
                          style: GoogleFonts.ubuntu(
                            textStyle: TextStyle(
                              color: Color(0xFFDC4654),
                              fontSize: 17.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Color(0xFFDC4654),
                      thickness: 2,
                    ),
                    FutureBuilder<List<Issue>?>(
                      future: getSavedList,
                      builder: ((context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            width: size.width,
                            height: 0.3 * size.height,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF737373),
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return buildSavedIssues(size, snapshot.data);
                        }
                      }),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
