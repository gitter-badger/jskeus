;; test code for robot usage

(require :unittest "lib/llib/unittest.l")
(init-unit-test)

(load "irteus/demo/sample-robot-model.l")
(unless (boundp '*robot*)
  (setq *robot* (instance sample-robot :init)))

(deftest test-properties
  ;; accessor of links
  (assert (send *robot* :links) (format nil "links accessor"))
  ;; accessor of limb links
  (dolist (l '(:rarm :larm :rleg :lleg :head :torso))
    (assert (send *robot* l :links) (format nil "limb links accessor")))
  ;; accessor of joint-list
  (assert (send *robot* :joint-list) (format nil "joint-list accessor"))
  ;; accessor of limb joint-list
  (dolist (l '(:rarm :larm :rleg :lleg :head :torso))
    (assert (send *robot* l :joint-list) (format nil "limb joint-list accessor")))
  ;; accessor of link
  (dolist (l (send *robot* :links))
    (assert (send *robot* :link (send l :name)) (format nil "link accessor (~18A)" (send l :name))))
  ;; accessor of joint
  (dolist (j (send *robot* :joint-list))
    (assert (send *robot* :joint (send j :name)) (format nil "joint accessor (~18A)" (send j :name))))
  ;; accessor of end-coords
  (dolist (l '(:rarm :larm :rleg :lleg :head))
    (assert (send *robot* l :end-coords) (format nil "end-coords accessor (~8A)" l)))
  ;; accessor of mass properties
  (dolist (l (send *robot* :links))
    (assert (and (numberp (send l :weight)) (vectorp (l . acentroid)) (arrayp (send l :inertia-tensor)))
            (format nil "link mass properties accessor (~18A)" (send l :name))))
  ;; accessor of joint
  (dolist (j (send *robot* :joint-list))
    (assert (and (send j :min-angle) (send j :max-angle) (send j :max-joint-velocity) (send j :max-joint-torque))
            (format nil "joint properties accessor (~18A)" (send j :name))))
  ;; accessor of sensors
  (dolist (sensor-type '(:camera :force-sensor :imu-sensor))
    (assert (send *robot* (read-from-string (format nil "~As" sensor-type)))
            (format nil "~As accessor" sensor-type)))
  ;; accessor of limb sensors
  (assert (send *robot* :head :cameras) (format nil "limb :cameras accessor"))
  (assert (send *robot* :torso :imu-sensors) (format nil "limb :imu-sensors accessor"))
  (dolist (l '(:rarm :larm :rleg :lleg))
    (assert (send *robot* l :force-sensors)) (format nil "limb :force-sensors accessor"))
  ;; accessor of sensor
  (dolist (sensor-type '(:camera :force-sensor :imu-sensor))
    (dolist (sen (send *robot* (read-from-string (format nil "~As" sensor-type))))
      (assert (send *robot* sensor-type (send sen :name))
              (format nil "~A accessor" sensor-type))))
  )

(deftest test-lookat
  (let ((ret) (gaze-dir) (target-dir))
    (dolist (yaw (list -150 150))
      (dolist (target (list #f(-100 -200 350) #f(0 -200 350) #f(200 -200 350)
                            #f(200 0 350)
                            #f(200 200 350) #f(0 200 350) #f(-100 200 350)))
        (send *robot* :head :neck-p :joint-angle 0)
        (send *robot* :head :neck-y :joint-angle yaw)
        ;;(send *irtviewer* :draw-objects)
        (setq ret (send *robot* :head :look-at target :debug-view t))
        (setq gaze-dir (matrix-column (send *robot* :head :end-coords :worldrot) 2))
        (setq target-dir (normalize-vector (v- target (send *robot* :head :end-coords :worldpos))))
        (format t "ret = ~A, (v. gaze-dir target-dir) = ~A~%" ret (v. gaze-dir target-dir))
        (assert (and ret (> (v. gaze-dir target-dir) 0.9)) "look-at-ik failed")
        ))
    ))


(run-all-tests)
(exit)
