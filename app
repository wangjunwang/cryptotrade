import React, { useState, useMemo, useRef, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  TextInput,
  Image,
  Modal,
  Dimensions,
  StatusBar,
  Alert,
  Platform,
  SafeAreaView,
  Animated,
} from 'react-native';
// 注意：你需要安装 react-native-svg 和 react-native-image-picker
import Svg, { Path, Line, Circle, Polyline, Rect } from 'react-native-svg';

// --- 屏幕尺寸工具 ---
const { width, height } = Dimensions.get('window');

// --- 图标组件 (使用 react-native-svg) ---
const IconBase = ({ children, size = 24, color = "#64748B", style }: any) => (
  <View style={style}>
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      {children}
    </Svg>
  </View>
);

const CalendarIcon = (props: any) => (
  <IconBase {...props}>
    <Rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
    <Line x1="16" y1="2" x2="16" y2="6" />
    <Line x1="8" y1="2" x2="8" y2="6" />
    <Line x1="3" y1="10" x2="21" y2="10" />
  </IconBase>
);

const UsersIcon = (props: any) => (
  <IconBase {...props}>
    <Path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
    <Circle cx="9" cy="7" r="4" />
    <Path d="M23 21v-2a4 4 0 0 0-3-3.87" />
    <Path d="M16 3.13a4 4 0 0 1 0 7.75" />
  </IconBase>
);

const UserIcon = (props: any) => (
  <IconBase {...props}>
    <Path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
    <Circle cx="12" cy="7" r="4" />
  </IconBase>
);

const LightbulbIcon = (props: any) => (
  <IconBase {...props}>
    <Path d="M15 14c.2-1 .7-1.7 1.5-2.5 1-1 1.5-2 1.5-3.5A6 6 0 0 0 6 8c0 1 .2 2.2 1.5 3.5.7.7 1.3 1.5 1.5 2.5" />
    <Path d="M9 18h6" />
    <Path d="M10 22h4" />
  </IconBase>
);

const PlusIcon = (props: any) => (
  <IconBase {...props}>
    <Line x1="12" y1="5" x2="12" y2="19" />
    <Line x1="5" y1="12" x2="19" y2="12" />
  </IconBase>
);

const ChevronLeftIcon = (props: any) => (
  <IconBase {...props}>
    <Polyline points="15 18 9 12 15 6" />
  </IconBase>
);

const ChevronRightIcon = (props: any) => (
  <IconBase {...props}>
    <Polyline points="9 18 15 12 9 6" />
  </IconBase>
);

const Trash2Icon = (props: any) => (
  <IconBase {...props}>
    <Polyline points="3 6 5 6 21 6" />
    <Path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
    <Line x1="10" y1="11" x2="10" y2="17" />
    <Line x1="14" y1="11" x2="14" y2="17" />
  </IconBase>
);

const CameraIcon = (props: any) => (
  <IconBase {...props}>
    <Path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z" />
    <Circle cx="12" cy="13" r="4" />
  </IconBase>
);

const XIcon = (props: any) => (
  <IconBase {...props}>
    <Line x1="18" y1="6" x2="6" y2="18" />
    <Line x1="6" y1="6" x2="18" y2="18" />
  </IconBase>
);

const CheckIcon = (props: any) => (
  <IconBase {...props}>
     <Polyline points="20 6 9 17 4 12" />
  </IconBase>
);


// --- 模拟数据 ---
const INITIAL_STUDENTS = [
  { id: 1, name: '张子轩', totalHours: 20, remainingHours: 4, paymentDate: '2023-10-15', note: '钢琴基础' },
  { id: 2, name: '李小雅', totalHours: 10, remainingHours: 8, paymentDate: '2023-11-01', note: '奥数竞赛班' },
  { id: 3, name: '王浩', totalHours: 15, remainingHours: 12, paymentDate: '2023-11-10', note: '英语口语' },
];

const INITIAL_EVENTS = [
  { id: 101, date: new Date().toISOString().split('T')[0], type: 'class', studentId: 1, status: 'completed', time: '14:00' },
  { id: 102, date: new Date().toISOString().split('T')[0], type: 'inspiration', content: '今天发现一个新的教学方法，可以用游戏来引入函数概念！', time: '16:30', image: null },
];

// --- 辅助组件 ---
const Card = ({ children, style, noPadding }: any) => (
  <View style={[styles.card, noPadding && { padding: 0 }, style]}>
    {children}
  </View>
);

const Button = ({ children, onPress, variant = 'primary', style, disabled }: any) => {
  const getBgColor = () => {
    if (disabled) return variant === 'primary' ? '#93C5FD' : '#FDBA74';
    if (variant === 'primary') return '#2563EB';
    if (variant === 'secondary') return '#F97316';
    if (variant === 'danger') return '#FEF2F2';
    return 'transparent';
  };

  const getTextColor = () => {
    if (variant === 'danger') return '#DC2626';
    if (variant === 'ghost') return '#64748B';
    return '#FFFFFF';
  };

  return (
    <TouchableOpacity 
      onPress={onPress} 
      disabled={disabled} 
      style={[
        styles.button, 
        { backgroundColor: getBgColor() },
        style
      ]}
    >
      <Text style={[styles.buttonText, { color: getTextColor() }]}>{children}</Text>
    </TouchableOpacity>
  );
};

// --- Bottom Sheet 组件 (原生动画实现) ---
const BottomSheet = ({ isOpen, onClose, title, children }: any) => {
  const slideAnim = useRef(new Animated.Value(height)).current;

  useEffect(() => {
    if (isOpen) {
      Animated.spring(slideAnim, {
        toValue: 0,
        useNativeDriver: true,
        bounciness: 4,
      }).start();
    } else {
      Animated.timing(slideAnim, {
        toValue: height,
        duration: 300,
        useNativeDriver: true,
      }).start();
    }
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <View style={StyleSheet.absoluteFillObject} pointerEvents="box-none">
      <TouchableOpacity style={styles.backdrop} activeOpacity={1} onPress={onClose} />
      <Animated.View style={[styles.bottomSheet, { transform: [{ translateY: slideAnim }] }]}>
        <View style={styles.dragIndicator} />
        <View style={styles.sheetHeader}>
          <Text style={styles.sheetTitle}>{title}</Text>
          <TouchableOpacity onPress={onClose} style={styles.iconBtn}>
            <XIcon size={20} color="#64748B" />
          </TouchableOpacity>
        </View>
        <ScrollView style={styles.sheetContent} showsVerticalScrollIndicator={false}>
          {children}
          <View style={{ height: 40 }} /> 
        </ScrollView>
      </Animated.View>
    </View>
  );
};

// --- 主应用 ---
export default function App() {
  const [activeTab, setActiveTab] = useState('calendar');
  const [currentDate, setCurrentDate] = useState(new Date());
  const [students, setStudents] = useState(INITIAL_STUDENTS);
  const [events, setEvents] = useState(INITIAL_EVENTS);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSheetOpen, setIsSheetOpen] = useState(false);
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [modalType, setModalType] = useState('class');
  const [formData, setFormData] = useState<any>({ studentId: '', time: '10:00', content: '', image: null });

  // --- 逻辑处理 ---
  const daysInMonth = (date: Date) => new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
  const firstDayOfMonth = (date: Date) => new Date(date.getFullYear(), date.getMonth(), 1).getDay();

  const generateCalendarDays = () => {
    const days = [];
    const totalDays = daysInMonth(currentDate);
    const startDay = firstDayOfMonth(currentDate);
    for (let i = 0; i < startDay; i++) days.push(null);
    for (let i = 1; i <= totalDays; i++) days.push(new Date(currentDate.getFullYear(), currentDate.getMonth(), i));
    return days;
  };

  const formatDateStr = (date: Date | null) => date ? date.toISOString().split('T')[0] : '';
  const changeMonth = (delta: number) => setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + delta, 1));

  // 拍照逻辑 (需集成 react-native-image-picker)
  const handleImagePick = async () => {
    Alert.alert("提示", "此处需集成 react-native-image-picker 库来调用原生相机/相册");
    // 实际代码示例:
    // const result = await launchImageLibrary({ mediaType: 'photo' });
    // if (result.assets) setFormData({...formData, image: result.assets[0].uri});
  };

  const handleAddEvent = () => {
    if (modalType === 'class' && !formData.studentId) return Alert.alert('提示', '请选择学生');
    if (modalType === 'inspiration' && !formData.content) return Alert.alert('提示', '请输入内容');

    const newEvent = {
      id: Date.now(),
      date: formatDateStr(selectedDate),
      type: modalType,
      studentId: modalType === 'class' ? parseInt(formData.studentId) : null,
      content: formData.content,
      image: formData.image,
      time: formData.time,
      status: 'scheduled'
    };

    setEvents([...events, newEvent]);
    setIsModalOpen(false);
    setIsSheetOpen(true); // 添加后打开详情页
    setFormData({ studentId: '', time: '10:00', content: '', image: null });
  };

  const handleAddStudent = () => {
    if (!formData.studentName) return;
    const newStudent = {
      id: Date.now(),
      name: formData.studentName,
      totalHours: parseInt(formData.totalHours) || 0,
      remainingHours: parseInt(formData.totalHours) || 0,
      paymentDate: new Date().toISOString().split('T')[0],
      note: formData.studentNote || ''
    };
    setStudents([...students, newStudent]);
    setIsModalOpen(false);
    setFormData({ studentId: '', time: '10:00', content: '', image: null });
  };

  const verifyClass = (eventId: number) => {
    const event = events.find(e => e.id === eventId);
    if (!event || event.status === 'completed') return;

    const updatedStudents = students.map(s => {
      if (s.id === event.studentId) return { ...s, remainingHours: s.remainingHours - 1 };
      return s;
    });

    const updatedEvents = events.map(e => {
      if (e.id === eventId) return { ...e, status: 'completed' };
      return e;
    });

    setStudents(updatedStudents);
    setEvents(updatedEvents);
  };

  const deleteEvent = (eventId: number) => setEvents(events.filter(e => e.id !== eventId));
  const getEventsForDay = (date: Date | null) => {
    if (!date) return [];
    const dateStr = formatDateStr(date);
    return events.filter(e => e.date === dateStr);
  };

  const openAddModalFromSheet = (type: string) => {
    setModalType(type);
    setIsModalOpen(true);
  };

  // --- 渲染组件 ---
  const renderCalendar = () => {
    const days = generateCalendarDays();
    const weeks = ['日', '一', '二', '三', '四', '五', '六'];

    return (
      <View style={styles.tabContent}>
        {/* Header */}
        <View style={styles.calendarHeader}>
          <TouchableOpacity onPress={() => changeMonth(-1)} style={styles.iconBtn}>
            <ChevronLeftIcon />
          </TouchableOpacity>
          <View style={{alignItems: 'center'}}>
            <Text style={styles.monthText}>{currentDate.getMonth() + 1}月</Text>
            <Text style={styles.yearText}>{currentDate.getFullYear()}</Text>
          </View>
          <TouchableOpacity onPress={() => changeMonth(1)} style={styles.iconBtn}>
            <ChevronRightIcon />
          </TouchableOpacity>
        </View>

        {/* Weeks */}
        <View style={styles.weekRow}>
          {weeks.map(w => (
            <Text key={w} style={styles.weekText}>{w}</Text>
          ))}
        </View>

        {/* Days */}
        <View style={styles.daysGrid}>
          {days.map((date, index) => {
            const dayEvents = getEventsForDay(date);
            const isToday = date && formatDateStr(date) === formatDateStr(new Date());
            const hasClass = dayEvents.some(e => e.type === 'class');
            const hasInspiration = dayEvents.some(e => e.type === 'inspiration');

            return (
              <TouchableOpacity
                key={index}
                onPress={() => {
                  if (date) {
                    setSelectedDate(date);
                    setIsSheetOpen(true);
                  }
                }}
                style={styles.dayCell}
                disabled={!date}
              >
                {date && (
                  <>
                    <View style={[styles.dayNumberContainer, isToday && styles.dayNumberToday]}>
                      <Text style={[styles.dayNumberText, isToday && {color: '#fff'}]}>{date.getDate()}</Text>
                    </View>
                    <View style={styles.dotContainer}>
                      {hasClass && <View style={[styles.dot, {backgroundColor: '#3B82F6'}]} />}
                      {hasInspiration && <View style={[styles.dot, {backgroundColor: '#F97316'}]} />}
                    </View>
                  </>
                )}
              </TouchableOpacity>
            );
          })}
        </View>

        {/* Overview Card */}
        <View style={styles.overviewCard}>
          <View>
            <Text style={styles.overviewLabel}>今日概览</Text>
            <Text style={styles.overviewCount}>{getEventsForDay(new Date()).length} 项日程</Text>
          </View>
          <View style={styles.overviewIcon}>
            <CalendarIcon color="#3B82F6" />
          </View>
        </View>
      </View>
    );
  };

  const renderStudents = () => (
    <ScrollView style={styles.tabContent} contentContainerStyle={{paddingBottom: 100}}>
      <View style={styles.sectionHeader}>
        <Text style={styles.sectionTitle}>学生管理</Text>
        <Button onPress={() => { setModalType('student_add'); setIsModalOpen(true); }} style={{paddingVertical: 8, paddingHorizontal: 12}}>
          <View style={{flexDirection: 'row', alignItems: 'center'}}>
            <PlusIcon size={16} color="#FFF" />
            <Text style={{color: '#FFF', fontWeight: 'bold', marginLeft: 4}}>新增</Text>
          </View>
        </Button>
      </View>

      {students.map(student => (
        <Card key={student.id} style={styles.studentCard}>
          <View style={{flexDirection: 'row', alignItems: 'center'}}>
            <View style={styles.avatar}>
              <Text style={styles.avatarText}>{student.name[0]}</Text>
            </View>
            <View style={{marginLeft: 12}}>
              <View style={{flexDirection: 'row', alignItems: 'center'}}>
                <Text style={styles.studentName}>{student.name}</Text>
                {student.remainingHours <= 3 && (
                  <View style={styles.badge}>
                    <Text style={styles.badgeText}>余额不足</Text>
                  </View>
                )}
              </View>
              <Text style={styles.studentMeta}>{student.note}</Text>
            </View>
          </View>
          <View style={{alignItems: 'flex-end'}}>
            <Text style={styles.metaLabel}>剩余课时</Text>
            <Text style={[styles.hourCount, student.remainingHours <= 3 ? {color: '#EF4444'} : {color: '#2563EB'}]}>
              {student.remainingHours} <Text style={{fontSize: 12, color: '#94A3B8'}}>/ {student.totalHours}</Text>
            </Text>
          </View>
        </Card>
      ))}
    </ScrollView>
  );

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="#fff" />
      
      {/* Top Bar */}
      <View style={styles.topBar}>
        <Text style={styles.appTitle}>课时记</Text>
        <TouchableOpacity style={styles.userBtn}>
          <UserIcon size={20} color="#94A3B8" />
        </TouchableOpacity>
      </View>

      {/* Content */}
      <View style={{flex: 1}}>
        {activeTab === 'calendar' && renderCalendar()}
        {activeTab === 'students' && renderStudents()}
        {/* Note: Inspirations tab simplified for demo, access via sheet */}
      </View>

      {/* Bottom Nav */}
      <View style={styles.bottomNavContainer}>
        <View style={styles.bottomNav}>
          <TouchableOpacity onPress={() => setActiveTab('calendar')} style={[styles.navBtn, activeTab === 'calendar' && styles.navBtnActive]}>
            <CalendarIcon color={activeTab === 'calendar' ? '#FFF' : '#94A3B8'} size={20} />
          </TouchableOpacity>

          <TouchableOpacity 
            onPress={() => { setSelectedDate(new Date()); openAddModalFromSheet('class'); }}
            style={styles.fabBtn}
          >
             <PlusIcon color="#FFF" size={28} />
          </TouchableOpacity>

          <TouchableOpacity onPress={() => setActiveTab('students')} style={[styles.navBtn, activeTab === 'students' && styles.navBtnActive]}>
            <UsersIcon color={activeTab === 'students' ? '#FFF' : '#94A3B8'} size={20} />
          </TouchableOpacity>
        </View>
      </View>

      {/* Bottom Sheet Details */}
      <BottomSheet 
        isOpen={isSheetOpen} 
        onClose={() => setIsSheetOpen(false)} 
        title={selectedDate ? `${selectedDate.getMonth()+1}月${selectedDate.getDate()}日` : '详情'}
      >
        <View style={{flexDirection: 'row', gap: 12, marginBottom: 24}}>
          <TouchableOpacity 
            onPress={() => openAddModalFromSheet('class')}
            style={[styles.actionBtn, {backgroundColor: '#EFF6FF'}]}
          >
            <UsersIcon size={18} color="#2563EB" />
            <Text style={{color: '#2563EB', fontWeight: 'bold', marginLeft: 6}}>排一节课</Text>
          </TouchableOpacity>
          <TouchableOpacity 
            onPress={() => openAddModalFromSheet('inspiration')}
            style={[styles.actionBtn, {backgroundColor: '#FFF7ED'}]}
          >
            <LightbulbIcon size={18} color="#F97316" />
            <Text style={{color: '#F97316', fontWeight: 'bold', marginLeft: 6}}>记个灵感</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.timeline}>
          {getEventsForDay(selectedDate).length === 0 ? (
            <Text style={{textAlign: 'center', color: '#94A3B8', fontStyle: 'italic', marginTop: 20}}>暂无安排</Text>
          ) : (
            getEventsForDay(selectedDate).sort((a,b)=>a.time > b.time ? 1 : -1).map(ev => {
              const student = students.find(s => s.id === ev.studentId);
              return (
                <View key={ev.id} style={styles.timelineItem}>
                   <View style={[styles.timelineDot, {borderColor: ev.type === 'class' ? (ev.status === 'completed' ? '#22C55E' : '#3B82F6') : '#F97316'}]} />
                   <View style={{flex: 1}}>
                      <Text style={styles.timeText}>{ev.time}</Text>
                      <Text style={styles.eventTitle}>{ev.type === 'class' ? `${student?.name} · 课程` : '灵感笔记'}</Text>
                      
                      {ev.type === 'inspiration' && (
                        <View style={styles.inspirationBox}>
                          <Text style={{color: '#334155'}}>{ev.content}</Text>
                        </View>
                      )}
                      
                      {ev.type === 'class' && (
                        <Text style={{color: '#64748B', fontSize: 12, marginTop: 2}}>
                          {ev.status === 'completed' ? '已完成' : '待上课'}
                        </Text>
                      )}
                   </View>

                   <View style={{justifyContent: 'center', gap: 8}}>
                      {ev.type === 'class' && ev.status !== 'completed' && (
                        <TouchableOpacity onPress={() => verifyClass(ev.id)} style={styles.checkBtn}>
                           <CheckIcon size={16} color="#2563EB" />
                        </TouchableOpacity>
                      )}
                      <TouchableOpacity onPress={() => deleteEvent(ev.id)}>
                        <Trash2Icon size={16} color="#CBD5E1" />
                      </TouchableOpacity>
                   </View>
                </View>
              )
            })
          )}
        </View>
      </BottomSheet>

      {/* Modal Form */}
      <Modal visible={isModalOpen} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>
              {modalType === 'class' ? '排一节课' : (modalType === 'inspiration' ? '记录灵感' : '新增学生')}
            </Text>

            {modalType === 'student_add' ? (
              <>
                <TextInput style={styles.input} placeholder="学生姓名" onChangeText={t => setFormData({...formData, studentName: t})} />
                <TextInput style={styles.input} placeholder="购买课时" keyboardType="numeric" onChangeText={t => setFormData({...formData, totalHours: t})} />
                <TextInput style={styles.input} placeholder="备注" onChangeText={t => setFormData({...formData, studentNote: t})} />
              </>
            ) : modalType === 'class' ? (
              <>
                {/* 简化版 Picker, 实际可使用 @react-native-picker/picker */}
                <Text style={{marginBottom: 8, color: '#64748B'}}>选择学生ID (输入ID):</Text>
                <View style={{flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginBottom: 16}}>
                  {students.map(s => (
                    <TouchableOpacity 
                      key={s.id} 
                      onPress={() => setFormData({...formData, studentId: s.id.toString()})}
                      style={[styles.chip, formData.studentId == s.id && styles.chipActive]}
                    >
                       <Text style={[styles.chipText, formData.studentId == s.id && {color: '#fff'}]}>{s.name}</Text>
                    </TouchableOpacity>
                  ))}
                </View>
                <TextInput style={styles.input} placeholder="时间 (例如 14:00)" value={formData.time} onChangeText={t => setFormData({...formData, time: t})} />
              </>
            ) : (
              <>
                 <TextInput 
                   style={[styles.input, {height: 100, textAlignVertical: 'top'}]} 
                   placeholder="写下你的想法..." 
                   multiline 
                   onChangeText={t => setFormData({...formData, content: t})} 
                 />
                 <TouchableOpacity onPress={handleImagePick} style={styles.uploadBox}>
                    <CameraIcon color="#94A3B8" />
                    <Text style={{color: '#94A3B8', marginTop: 8}}>点击拍照/上传</Text>
                 </TouchableOpacity>
              </>
            )}

            <View style={{flexDirection: 'row', gap: 12, marginTop: 24}}>
              <Button variant="ghost" onPress={() => setIsModalOpen(false)} style={{flex: 1, backgroundColor: '#F1F5F9'}}>取消</Button>
              <Button onPress={modalType === 'student_add' ? handleAddStudent : handleAddEvent} style={{flex: 1}}>确认</Button>
            </View>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FFF' },
  topBar: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 24, paddingVertical: 12 },
  appTitle: { fontSize: 24, fontWeight: '900', color: '#0F172A' },
  userBtn: { width: 36, height: 36, borderRadius: 18, backgroundColor: '#F8FAFC', alignItems: 'center', justifyContent: 'center' },
  
  // Tab Content
  tabContent: { flex: 1, paddingHorizontal: 16 },
  
  // Calendar
  calendarHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16, paddingHorizontal: 8 },
  monthText: { fontSize: 20, fontWeight: '900', color: '#1E293B' },
  yearText: { fontSize: 12, fontWeight: 'bold', color: '#94A3B8', letterSpacing: 1, marginTop: 2 },
  iconBtn: { padding: 8 },
  weekRow: { flexDirection: 'row', marginBottom: 12 },
  weekText: { flex: 1, textAlign: 'center', fontSize: 12, fontWeight: 'bold', color: '#CBD5E1' },
  daysGrid: { flexDirection: 'row', flexWrap: 'wrap' },
  dayCell: { width: '14.28%', height: 60, alignItems: 'center', justifyContent: 'flex-start' },
  dayNumberContainer: { width: 36, height: 36, borderRadius: 18, alignItems: 'center', justifyContent: 'center', marginBottom: 4 },
  dayNumberToday: { backgroundColor: '#2563EB', shadowColor: '#3B82F6', shadowOpacity: 0.3, shadowRadius: 4, elevation: 4 },
  dayNumberText: { fontSize: 14, fontWeight: '600', color: '#334155' },
  dotContainer: { flexDirection: 'row', gap: 4 },
  dot: { width: 6, height: 6, borderRadius: 3 },
  
  // Overview Card
  overviewCard: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', backgroundColor: '#EFF6FF', padding: 20, borderRadius: 24, marginTop: 20, marginHorizontal: 8 },
  overviewLabel: { fontSize: 12, fontWeight: 'bold', color: '#60A5FA', letterSpacing: 1, marginBottom: 4 },
  overviewCount: { fontSize: 20, fontWeight: '900', color: '#1E293B' },
  overviewIcon: { width: 48, height: 48, backgroundColor: '#FFF', borderRadius: 16, alignItems: 'center', justifyContent: 'center' },

  // Students
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16, marginTop: 8 },
  sectionTitle: { fontSize: 20, fontWeight: 'bold', color: '#0F172A' },
  studentCard: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 },
  avatar: { width: 48, height: 48, borderRadius: 24, backgroundColor: '#F1F5F9', alignItems: 'center', justifyContent: 'center', borderWidth: 2, borderColor: '#FFF' },
  avatarText: { fontSize: 18, fontWeight: 'bold', color: '#475569' },
  studentName: { fontSize: 16, fontWeight: 'bold', color: '#1E293B' },
  badge: { backgroundColor: '#FEE2E2', paddingHorizontal: 6, paddingVertical: 2, borderRadius: 4, marginLeft: 8 },
  badgeText: { fontSize: 10, color: '#DC2626', fontWeight: 'bold' },
  studentMeta: { fontSize: 12, color: '#64748B', marginTop: 4 },
  metaLabel: { fontSize: 10, color: '#94A3B8', fontWeight: 'bold', textAlign: 'right' },
  hourCount: { fontSize: 20, fontWeight: '900' },

  // Shared
  card: { backgroundColor: '#FFF', borderRadius: 20, padding: 16, borderWidth: 1, borderColor: '#F8FAFC', shadowColor: "#000", shadowOffset: {width: 0, height: 2}, shadowOpacity: 0.05, shadowRadius: 8, elevation: 2 },
  button: { paddingVertical: 12, paddingHorizontal: 16, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  buttonText: { fontWeight: 'bold', fontSize: 14 },
  
  // Bottom Nav
  bottomNavContainer: { position: 'absolute', bottom: 24, left: 24, right: 24 },
  bottomNav: { flexDirection: 'row', justifyContent: 'space-around', alignItems: 'center', backgroundColor: '#FFF', paddingVertical: 12, borderRadius: 32, shadowColor: "#000", shadowOffset: {width: 0, height: 4}, shadowOpacity: 0.1, shadowRadius: 12, elevation: 8 },
  navBtn: { width: 48, height: 48, alignItems: 'center', justifyContent: 'center', borderRadius: 16 },
  navBtnActive: { backgroundColor: '#0F172A' },
  fabBtn: { width: 56, height: 56, borderRadius: 28, backgroundColor: '#2563EB', alignItems: 'center', justifyContent: 'center', marginTop: -24, borderWidth: 4, borderColor: '#FFF' },

  // Bottom Sheet
  backdrop: { flex: 1, backgroundColor: 'rgba(0,0,0,0.3)' },
  bottomSheet: { height: height * 0.85, backgroundColor: '#FFF', borderTopLeftRadius: 32, borderTopRightRadius: 32, padding: 24, marginTop: 'auto', shadowColor: "#000", shadowOffset: {width: 0, height: -4}, shadowOpacity: 0.1, shadowRadius: 12, elevation: 10 },
  dragIndicator: { width: 48, height: 6, backgroundColor: '#E2E8F0', borderRadius: 3, alignSelf: 'center', marginBottom: 24 },
  sheetHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 },
  sheetTitle: { fontSize: 20, fontWeight: '900', color: '#0F172A' },
  sheetContent: { flex: 1 },
  actionBtn: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', padding: 16, borderRadius: 16 },
  
  // Timeline
  timeline: { borderLeftWidth: 2, borderLeftColor: '#F1F5F9', marginLeft: 16, paddingLeft: 24, paddingVertical: 8 },
  timelineItem: { marginBottom: 32, flexDirection: 'row', gap: 16 },
  timelineDot: { position: 'absolute', left: -31, top: 4, width: 12, height: 12, borderRadius: 6, backgroundColor: '#FFF', borderWidth: 3 },
  timeText: { fontSize: 12, fontWeight: 'bold', color: '#94A3B8', marginBottom: 4 },
  eventTitle: { fontSize: 16, fontWeight: 'bold', color: '#1E293B' },
  inspirationBox: { backgroundColor: '#F8FAFC', padding: 12, borderRadius: 12, marginTop: 8, borderWidth: 1, borderColor: '#F1F5F9' },
  checkBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: '#EFF6FF', alignItems: 'center', justifyContent: 'center' },

  // Modal
  modalOverlay: { flex: 1, backgroundColor: 'rgba(15, 23, 42, 0.5)', justifyContent: 'center', padding: 24 },
  modalContent: { backgroundColor: '#FFF', borderRadius: 32, padding: 24 },
  modalTitle: { fontSize: 20, fontWeight: '900', color: '#0F172A', marginBottom: 24 },
  input: { backgroundColor: '#F8FAFC', padding: 16, borderRadius: 16, fontSize: 16, fontWeight: '600', color: '#334155', marginBottom: 12 },
  chip: { paddingHorizontal: 12, paddingVertical: 8, borderRadius: 20, backgroundColor: '#F1F5F9' },
  chipActive: { backgroundColor: '#2563EB' },
  chipText: { fontSize: 12, fontWeight: 'bold', color: '#64748B' },
  uploadBox: { height: 100, borderStyle: 'dashed', borderWidth: 2, borderColor: '#E2E8F0', borderRadius: 16, alignItems: 'center', justifyContent: 'center', marginTop: 8 },
});
```

### 2. 生成 APP 你还需做什么 (Android)

拿到上面的代码后，你离生成一个可以安装在手机上的 APK 还有以下几步：

#### 第一步：搭建开发环境 (如果你的电脑没有安装)
1.  安装 **Node.js**。
2.  安装 **Android Studio** (用于下载 Android SDK 和模拟器)。

#### 第二步：初始化项目
在你的电脑终端（Terminal/CMD）运行：
```bash
npx react-native init ClassLogApp
cd ClassLogApp
```

#### 第三步：安装依赖库
这个 App 使用了一些漂亮的图标和 SVG，你需要安装这些库：
```bash
# 安装 svg 支持
npm install react-native-svg

# 安装图片选择器 (用于灵感上传图片)
npm install react-native-image-picker

# 安装其他可能需要的类型定义 (如果是 TypeScript)
npm install --save-dev @types/react-native
```

#### 第四步：替换代码
1.  找到项目目录下的 `App.tsx` (或 `App.js`)。
2.  把**我上面生成的代码**全部复制进去，覆盖原文件。

#### 第五步：运行与打包
* **测试运行**：连接你的安卓手机（开启 USB 调试）或打开模拟器，运行：
    ```bash
    npm run android
    ```
* **生成安装包 (APK)**：
    当开发完成，想要发给别人时，在 `android` 目录下运行：
    ```bash
    cd android
    ./gradlew assembleRelease
