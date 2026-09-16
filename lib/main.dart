import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

const navy = Color(0xFF102A43), teal = Color(0xFF0E9F9A), orange = Color(0xFFF59E0B), bg = Color(0xFFF4F7FA);
const statuses = ['تم الاستلام','قيد الفحص','بانتظار موافقة الزبون','قيد الإصلاح','جاهز للتسليم','تم التسليم','لم يتم الإصلاح','ملغي'];

class Device {
  String id, customer, phone, type, model, status, notes, received, due;
  double amount, paid;
  Device({required this.id, required this.customer, required this.phone, required this.type, required this.model, required this.status, required this.received, required this.due, this.notes='', this.amount=0, this.paid=0});
  Map<String,dynamic> toJson()=>{'id':id,'customer':customer,'phone':phone,'type':type,'model':model,'status':status,'received':received,'due':due,'notes':notes,'amount':amount,'paid':paid};
  factory Device.fromJson(Map<String,dynamic> j)=>Device(id:j['id']??'',customer:j['customer']??'',phone:j['phone']??'',type:j['type']??'',model:j['model']??'',status:j['status']??statuses.first,received:j['received']??'',due:j['due']??'',notes:j['notes']??'',amount:(j['amount']??0).toDouble(),paid:(j['paid']??0).toDouble());
}

void main()=>runApp(const SabrApp());
class SabrApp extends StatelessWidget { const SabrApp({super.key}); @override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false, title:'صبر إلكترونكس', theme:ThemeData(useMaterial3:true, scaffoldBackgroundColor:bg, colorScheme:ColorScheme.fromSeed(seedColor:teal), fontFamily:'Arial', inputDecorationTheme:const InputDecorationTheme(filled:true, fillColor:Colors.white, border:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(12)), borderSide:BorderSide.none))), home:const Directionality(textDirection:TextDirection.rtl, child:Home())); }

class Home extends StatefulWidget { const Home({super.key}); @override State<Home> createState()=>_HomeState(); }
class _HomeState extends State<Home> {
  List<Device> devices=[]; int tab=0; String search='', filter='الكل'; bool loading=true;
  @override void initState(){super.initState(); load();}
  Future<void> load() async {final p=await SharedPreferences.getInstance(); final raw=p.getString('devices'); if(raw!=null) devices=(jsonDecode(raw) as List).map((e)=>Device.fromJson(e)).toList(); setState(()=>loading=false);}
  Future<void> save() async {final p=await SharedPreferences.getInstance(); await p.setString('devices',jsonEncode(devices.map((e)=>e.toJson()).toList())); setState((){});}
  List<Device> get visible {final q=search.trim().toLowerCase(); return devices.where((d)=>(filter=='الكل'||d.status==filter)&&('${d.customer} ${d.phone} ${d.id} ${d.type} ${d.model}'.toLowerCase().contains(q))).toList();}
  int count(String s)=>devices.where((d)=>d.status==s).length;
  @override Widget build(BuildContext c){if(loading)return const Scaffold(body:Center(child:CircularProgressIndicator())); return Scaffold(appBar:AppBar(backgroundColor:navy,foregroundColor:Colors.white,title:const Text('صبر إلكترونكس',style:TextStyle(fontWeight:FontWeight.bold)),actions:[IconButton(onPressed:backup,icon:const Icon(Icons.ios_share),tooltip:'نسخ احتياطي'),IconButton(onPressed:restore,icon:const Icon(Icons.restore),tooltip:'استعادة')]),body:tab==0?dashboard():tab==1?devicesPage():reports(),bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),destinations:const [NavigationDestination(icon:Icon(Icons.dashboard_outlined),selectedIcon:Icon(Icons.dashboard),label:'الرئيسية'),NavigationDestination(icon:Icon(Icons.devices_other),label:'الأجهزة'),NavigationDestination(icon:Icon(Icons.insights),label:'التقارير')]),floatingActionButton:tab==1?FloatingActionButton.extended(backgroundColor:teal,foregroundColor:Colors.white,onPressed:()=>edit(),icon:const Icon(Icons.add),label:const Text('جهاز جديد')):null);}
  Widget dashboard()=>SingleChildScrollView(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('أهلاً بك',style:TextStyle(fontSize:26,fontWeight:FontWeight.bold,color:navy)),const Text('ملخص العمل اليومي',style:TextStyle(color:Colors.blueGrey)),const SizedBox(height:18),Wrap(spacing:10,runSpacing:10,children:[stat('قيد المتابعة',devices.where((d)=>!['تم التسليم','ملغي'].contains(d.status)).length,teal,Icons.build),stat('جاهز للتسليم',count('جاهز للتسليم'),orange,Icons.inventory_2),stat('متأخر',devices.where((d)=>d.due.isNotEmpty&&DateTime.tryParse(d.due)!=null&&DateTime.parse(d.due).isBefore(DateTime.now())&&!['تم التسليم','ملغي'].contains(d.status)).length,Colors.red,Icons.warning),stat('المتحصل',devices.fold(0.0,(a,d)=>a+d.paid).round(),navy,Icons.payments)]),const SizedBox(height:24),sectionTitle('آخر الأجهزة'),...devices.take(5).map(deviceTile)]));
  Widget stat(String title, int value, Color color, IconData icon) => Container(
    width: MediaQuery.sizeOf(context).width / 2 - 22,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Row(children: [
      CircleAvatar(backgroundColor: color.withOpacity(.12), child: Icon(icon, color: color)),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$value', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(title, style: const TextStyle(fontSize: 12)),
      ]),
    ]),
  );
  Widget devicesPage() => Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: TextField(
      onChanged: (v) => setState(() => search = v),
      decoration: const InputDecoration(hintText: 'بحث بالاسم، الهاتف، الطلب أو الموديل', prefixIcon: Icon(Icons.search)),
    )),
    SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(
      children: ['الكل', ...statuses].map((s) => Padding(
        padding: const EdgeInsets.only(left: 6),
        child: ChoiceChip(label: Text(s), selected: filter == s, onSelected: (_) => setState(() => filter = s)),
      )).toList(),
    )),
    const SizedBox(height: 8),
    Expanded(child: visible.isEmpty ? const Center(child: Text('لا توجد أجهزة مطابقة')) : ListView.builder(
      padding: const EdgeInsets.all(12), itemCount: visible.length, itemBuilder: (_, i) => deviceTile(visible[i]),
    )),
  ]);
  Widget deviceTile(Device d) => Card(color: Colors.white, margin: const EdgeInsets.only(bottom: 10), child: ListTile(
    onTap: () => details(d), leading: CircleAvatar(backgroundColor: teal.withOpacity(.12), child: const Icon(Icons.devices, color: teal)),
    title: Text('${d.type} — ${d.model}', style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text('${d.customer} • ${d.id}\n${d.phone}'), isThreeLine: true, trailing: statusChip(d.status),
  ));
  Widget statusChip(String s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(color: (s == 'جاهز للتسليم' ? orange : teal).withOpacity(.12), borderRadius: BorderRadius.circular(20)),
    child: Text(s, style: TextStyle(fontSize: 11, color: s == 'جاهز للتسليم' ? orange : teal, fontWeight: FontWeight.bold)),
  );
  Widget reports() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('التقارير', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: navy)), const SizedBox(height: 14),
    Card(color: Colors.white, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('توزيع الحالات', style: TextStyle(fontWeight: FontWeight.bold)),
      ...statuses.where((s) => count(s) > 0).map((s) => ListTile(contentPadding: EdgeInsets.zero, title: Text(s), trailing: Text('${count(s)}'), subtitle: LinearProgressIndicator(value: devices.isEmpty ? 0 : count(s) / devices.length, color: teal))),
    ]))),
    Card(color: Colors.white, child: ListTile(title: const Text('إجمالي قيمة الإصلاحات'), subtitle: Text('${devices.fold(0.0, (a, d) => a + d.amount).toStringAsFixed(2)} ريال'), leading: const Icon(Icons.account_balance_wallet, color: orange))),
    FilledButton.icon(onPressed: exportCsv, icon: const Icon(Icons.download), label: const Text('تصدير CSV ومشاركته')),
  ]);
  Widget sectionTitle(String s) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(s, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy)));
  Future<void> edit([Device? old]) async { final r = await showDialog<Device>(context: context, builder: (_) => DeviceForm(device: old)); if (r != null) { setState(() => old == null ? devices.insert(0, r) : devices[devices.indexOf(old)] = r); save(); } }
  void details(Device d) => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => Directionality(textDirection: TextDirection.rtl, child: Padding(padding: const EdgeInsets.all(20), child: Wrap(children: [
    Text('${d.type} — ${d.model}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navy)),
    ListTile(title: Text(d.customer), subtitle: Text('${d.phone}\nرقم الطلب: ${d.id}')),
    ListTile(title: const Text('الحالة'), trailing: DropdownButton<String>(value: d.status, items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (s) { if (s != null) { d.status = s; save(); Navigator.pop(context); } })),
    Text('المبلغ: ${d.amount} | المدفوع: ${d.paid}'), if (d.notes.isNotEmpty) Text('\nملاحظات: ${d.notes}'), const SizedBox(height: 12),
    Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => edit(d), icon: const Icon(Icons.edit), label: const Text('تعديل'))), const SizedBox(width: 8), Expanded(child: FilledButton.icon(onPressed: () => whatsapp(d), icon: const Icon(Icons.chat), label: const Text('واتساب')))]),
  ]))));
  Future<void> whatsapp(Device d)async{final u=Uri.parse('https://wa.me/${d.phone.replaceAll(RegExp(r'[^0-9]'), '')}?text=${Uri.encodeComponent('مرحباً ${d.customer}، تحديث جهازك ${d.type} ${d.model}: ${d.status} — صبر إلكترونكس')}');if(await canLaunchUrl(u))await launchUrl(u,mode:LaunchMode.externalApplication);}
  Future<void> exportCsv() async {final csv='رقم الطلب,الزبون,الهاتف,النوع,الموديل,الحالة,المبلغ,المدفوع\n${devices.map((d)=>'${d.id},${d.customer},${d.phone},${d.type},${d.model},${d.status},${d.amount},${d.paid}').join('\n')}';await Share.share(csv,subject:'تقرير صبر إلكترونكس');}
  Future<void> backup() async {await Share.share(jsonEncode(devices.map((d)=>d.toJson()).toList()),subject:'نسخة احتياطية - صبر إلكترونكس');}
  Future<void> restore()async{final result=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['json'],withData:true);if(result==null||result.files.single.bytes==null)return;try{final restored=(jsonDecode(utf8.decode(result.files.single.bytes!)) as List).map((e)=>Device.fromJson(e)).toList();setState(()=>devices=restored);await save();ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تمت استعادة النسخة الاحتياطية')));}catch(_){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('ملف النسخة الاحتياطية غير صالح')));}}
}

class DeviceForm extends StatefulWidget{final Device? device;const DeviceForm({super.key,this.device});@override State<DeviceForm> createState()=>_DeviceFormState();}
class _DeviceFormState extends State<DeviceForm>{final form=GlobalKey<FormState>();late TextEditingController customer,phone,type,model,notes,amount,paid;String status=statuses.first;DateTime due=DateTime.now().add(const Duration(days:3));@override void initState(){super.initState();final d=widget.device;customer=TextEditingController(text:d?.customer??'');phone=TextEditingController(text:d?.phone??'');type=TextEditingController(text:d?.type??'');model=TextEditingController(text:d?.model??'');notes=TextEditingController(text:d?.notes??'');amount=TextEditingController(text:d?.amount.toString()??'0');paid=TextEditingController(text:d?.paid.toString()??'0');status=d?.status??statuses.first;if(d?.due!=null&&DateTime.tryParse(d!.due)!=null)due=DateTime.parse(d.due);}
Widget field(TextEditingController c,String l,{TextInputType? keyboard})=>Padding(padding:const EdgeInsets.only(bottom:10),child:TextFormField(controller:c,keyboardType:keyboard,validator:(v)=>v==null||v.trim().isEmpty?'مطلوب':null,decoration:InputDecoration(labelText:l)));@override Widget build(BuildContext c)=>AlertDialog(title:Text(widget.device==null?'إضافة جهاز':'تعديل الجهاز'),content:SizedBox(width:420,child:Form(key:form,child:SingleChildScrollView(child:Column(children:[field(customer,'اسم الزبون'),field(phone,'رقم الهاتف',keyboard:TextInputType.phone),field(type,'نوع الجهاز'),field(model,'الموديل'),DropdownButtonFormField(value:status,decoration:const InputDecoration(labelText:'الحالة'),items:statuses.map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),onChanged:(v)=>setState(()=>status=v!),),field(amount,'المبلغ',keyboard:TextInputType.number),field(paid,'المدفوع',keyboard:TextInputType.number),field(notes,'ملاحظات')])))),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('إلغاء')),FilledButton(onPressed:(){if(form.currentState!.validate()){final d=Device(id:widget.device?.id??'SE-${DateFormat('yyMMddHHmm').format(DateTime.now())}',customer:customer.text,phone:phone.text,type:type.text,model:model.text,status:status,received:widget.device?.received??DateTime.now().toIso8601String(),due:due.toIso8601String(),notes:notes.text,amount:double.tryParse(amount.text)??0,paid:double.tryParse(paid.text)??0);Navigator.pop(c,d);}},child:const Text('حفظ'))]);}
}
