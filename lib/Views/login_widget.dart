import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Components/Model/login_model.dart';
import '../Controls/banco.dart';
import '../FlutterFlowTheme.dart';

///Página de login inicial
class LoginWidget extends StatefulWidget {

  ///Construtor da página de Login
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget>
    with TickerProviderStateMixin {

  late final Banco bd;

  late LoginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    bd = Banco(context);
    _model = createModel(context, LoginModel.new);

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    animationsMap.addAll({
      'columnOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => <Effect>[
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: 0,
            end: 1,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: const Offset(0, 60),
            end: const Offset(0, 0),
          ),
          TiltEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: const Offset(-0.349, 0),
            end: const Offset(0, 0),
          ),
        ],
      ),
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
              ))
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(0),
                      shape: BoxShape.rectangle,
                    ),
                    alignment: const AlignmentDirectional(0, 0),
                    child: Image.asset('assets/images/Multilist_compact.png'),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DefaultTabController(
                      length: 1,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context)
                              .secondaryBackground,
                        ),
                        child: Column(
                          children: [
                            TabBar(
                              labelColor: FlutterFlowTheme.of(context)
                                  .primaryText,
                              labelPadding: const EdgeInsets.all(16),
                              labelStyle: FlutterFlowTheme.of(context)
                                  .displaySmall
                                  .override(
                                fontFamily: 'Outfit',
                                letterSpacing: 0,
                              ),
                              indicatorColor: Colors.green.shade700,
                              indicatorWeight: 4,
                              isScrollable: true,
                              unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
                              unselectedLabelStyle:
                              FlutterFlowTheme.of(context).displaySmall.override(
                                fontFamily: 'Outfit',
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                              ),
                              tabs: const [
                                Tab(
                                  text: 'Login\n',
                                ),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  Align(
                                    alignment:
                                    const AlignmentDirectional(0, 0),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(12, 0, 12, 12),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                            const EdgeInsetsDirectional
                                                .fromSTEB(0, 40, 0, 16),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: TextFormField(
                                                onFieldSubmitted: (value){
                                                  setState(() {
                                                    _model.passwordFocusNode?.requestFocus();
                                                  });
                                                },
                                                controller: _model
                                                    .emailAddressTextController,
                                                focusNode: _model
                                                    .emailAddressFocusNode,
                                                autofocus: true,
                                                autofillHints: const [
                                                  AutofillHints.email
                                                ],
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  labelText: 'Login',
                                                  labelStyle:
                                                  FlutterFlowTheme.of(
                                                      context)
                                                      .labelMedium
                                                      .override(
                                                    fontFamily:
                                                    'Readex Pro',
                                                    letterSpacing:
                                                    0,
                                                  ),
                                                  enabledBorder:
                                                  OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: FlutterFlowTheme
                                                          .of(context)
                                                          .alternate,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(40),
                                                  ),
                                                  focusedBorder:
                                                  OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Colors
                                                          .green.shade700,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(40),
                                                  ),
                                                  errorBorder:
                                                  OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: FlutterFlowTheme
                                                          .of(context)
                                                          .error,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(40),
                                                  ),
                                                  focusedErrorBorder:
                                                  OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: FlutterFlowTheme
                                                          .of(context)
                                                          .error,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(40),
                                                  ),
                                                  filled: true,
                                                  fillColor: FlutterFlowTheme
                                                      .of(context)
                                                      .secondaryBackground,
                                                  contentPadding:
                                                  const EdgeInsets.all(
                                                      24),
                                                ),
                                                style: FlutterFlowTheme.of(
                                                    context)
                                                    .bodyMedium
                                                    .override(
                                                  fontFamily:
                                                  'Readex Pro',
                                                  letterSpacing: 0,
                                                ),
                                                keyboardType: TextInputType
                                                    .emailAddress,
                                                cursorColor:
                                                Colors.green.shade700,
                                                validator: _model
                                                    .emailAddressTextControllerValidator
                                                    .asValidator(context),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                            const EdgeInsetsDirectional
                                                .fromSTEB(0, 0, 0, 16),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: TextFormField(
                                                onFieldSubmitted: (value) async {
                                                  if (await bd.connected(context) == 1) {
                                                    if (context.mounted){
                                                      bd.auth(_model
                                                          .emailAddressTextController
                                                          .text, _model
                                                          .passwordTextController
                                                          .text, context,
                                                          bd);}
                                                    var prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    await prefs.setBool(
                                                        'logado', true);
                                                  }
                                                  setState(() {});
                                                },
                                                controller: _model
                                                    .passwordTextController,
                                                focusNode: _model
                                                    .passwordFocusNode,
                                                autofocus: false,
                                                autofillHints: const [
                                                  AutofillHints.password
                                                ],
                                                obscureText: !_model
                                                    .passwordVisibility,
                                                decoration: InputDecoration(
                                                  labelText: 'Senha',
                                                  labelStyle:
                                                  FlutterFlowTheme.of(
                                                      context)
                                                      .labelMedium
                                                      .override(
                                                    fontFamily:
                                                    'Readex Pro',
                                                    letterSpacing:
                                                    0,
                                                  ),
                                                  enabledBorder:
                                                  OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: FlutterFlowTheme
                                                          .of(context)
                                                          .alternate,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(40),
                                                  ),
                                                  focusedBorder:
                                                  OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Colors.green.shade700,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(40),
                                                  ),
                                                  errorBorder:
                                                  OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: FlutterFlowTheme
                                                          .of(context)
                                                          .error,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(40),
                                                  ),
                                                  focusedErrorBorder:
                                                  OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: FlutterFlowTheme
                                                          .of(context)
                                                          .error,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(40),
                                                  ),
                                                  filled: true,
                                                  fillColor: FlutterFlowTheme
                                                      .of(context)
                                                      .secondaryBackground,
                                                  contentPadding:
                                                  const EdgeInsets.all(
                                                      24),
                                                  suffixIcon: InkWell(
                                                    onTap: () => setState(
                                                          () => _model
                                                          .passwordVisibility =
                                                      !_model
                                                          .passwordVisibility,
                                                    ),
                                                    focusNode: FocusNode(
                                                        skipTraversal:
                                                        true),
                                                    child: Icon(
                                                      _model.passwordVisibility
                                                          ? Icons
                                                          .visibility_outlined
                                                          : Icons
                                                          .visibility_off_outlined,
                                                      color: FlutterFlowTheme
                                                          .of(context)
                                                          .secondaryText,
                                                      size: 24,
                                                    ),
                                                  ),
                                                ),
                                                style: FlutterFlowTheme.of(
                                                    context)
                                                    .bodyMedium
                                                    .override(
                                                  fontFamily:
                                                  'Readex Pro',
                                                  letterSpacing: 0,
                                                ),
                                                cursorColor:
                                                Colors.green.shade700,
                                                validator: _model
                                                    .passwordTextControllerValidator
                                                    .asValidator(context),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                            const AlignmentDirectional(
                                                0, 0),
                                            child: Padding(
                                              padding:
                                              const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                  0, 0, 0, 16),
                                              child: FFButtonWidget(
                                                onPressed: () async {
                                                  if (await bd.connected(context) == 1) {
                                                    if (context.mounted) {
                                                      bd.auth(_model
                                                          .emailAddressTextController
                                                          .text, _model
                                                          .passwordTextController
                                                          .text,
                                                          context,
                                                          bd);
                                                    }
                                                  }
                                                  setState(() {});
                                                },
                                                text: 'Logar',
                                                options: FFButtonOptions(
                                                  width: 230,
                                                  height: 52,
                                                  padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      0, 0, 0, 0),
                                                  iconPadding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      0, 0, 0, 0),
                                                  color:
                                                  Colors.green.shade700,
                                                  textStyle:
                                                  FlutterFlowTheme.of(
                                                      context)
                                                      .titleSmall
                                                      .override(
                                                    fontFamily:
                                                    'Readex Pro',
                                                    color: Colors
                                                        .white,
                                                    letterSpacing:
                                                    0,
                                                  ),
                                                  elevation: 3,
                                                  borderSide:
                                                  const BorderSide(
                                                    color:
                                                    Colors.transparent,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      40),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ).animateOnPageLoad(animationsMap[
                                      'columnOnPageLoadAnimation']!),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
